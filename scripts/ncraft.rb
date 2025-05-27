#!/usr/bin/env ruby

require 'thor'
require 'json'
require 'net/http'
require 'uri'
require 'logger'
require 'fileutils'
require 'colorize'
require 'open3'
require "anthropic"
require 'faraday'

class NCRAFT < Thor
  CONFIG_FILE = File.join(Dir.home, '.ncraft', 'config.json')
  PR_DRAFT_FILE = File.join(Dir.home, '.ncraft', 'PR_Draft')

  desc "create", "Create a branch and generate a PR draft from a Jira ticket"
  option :ticket, aliases: "-t", required: true, desc: "Jira ticket ID (e.g., PROJECT-123)"
  option :description, aliases: "-d", required: true, desc: "Short description for branch name"
  option :base, aliases: "-b", desc: "Base branch to create from (default: main)"

  def create
    load_config
    show_banner

    ticket = options[:ticket]
    description = options[:description]
    base_branch = options[:base] || @config["default_branch"] || "main"

    validate_ticket_format(ticket)
    ticket_info = get_jira_ticket(ticket)
    branch_name = create_branch(ticket, description, base_branch)

    puts "✓ Generated PR draft for #{branch_name}...".colorize(:green)

    # Generate and save PR draft
    pr_content = generate_pr_draft(ticket, ticket_info, branch_name, base_branch)

    # Print PR draft to console
    puts "\n" + "-" * 80
    puts "#{ticket}: #{description}".colorize(:yellow)
    puts "-" * 80
    puts "\n#{pr_content}".colorize(:blue)
    puts "-" * 80 + "\n"

    puts "\n✓ All done! Your PR draft has been saved to #{PR_DRAFT_FILE.to_s.colorize(:blue)}".colorize(:green)
  end

  desc "configure", "Configure NCRAFT settings"
  def configure
    puts "Configuring NCRAFT settings...".colorize(:blue)

    config = {}

    print "Jira API Token (default: #{JIRA_API_TOKEN}): ".colorize(:yellow)
    default_token = $stdin.gets.chomp
    config["jira_token"] = default_token.empty? ? JIRA_API_TOKEN : default_token

    print "Jira Email (default: #{JIRA_EMAIL}): ".colorize(:yellow)
    default_email = $stdin.gets.chomp
    config["jira_email"] = default_email.empty? ? JIRA_EMAIL : default_email

    print "Jira Base URL (default: #{JIRA_BASE_URL}): ".colorize(:yellow)
    jira_base_url = $stdin.gets.chomp
    config["jira_base_url"] = jira_base_url.empty? ? JIRA_BASE_URL : jira_base_url

    print "Default Base Branch (default: release): ".colorize(:yellow)
    default_branch = $stdin.gets.chomp
    config["default_branch"] = default_branch.empty? ? "release" : default_branch

    begin
      # Create config directory if it doesn't exist
      FileUtils.mkdir_p(File.dirname(CONFIG_FILE))

      # Write config to file
      File.open(CONFIG_FILE, 'w') do |file|
        file.write(JSON.pretty_generate(config))
      end

      # Secure the file with restricted permissions
      FileUtils.chmod(0600, CONFIG_FILE)

      puts "Configuration saved to #{CONFIG_FILE}".colorize(:green)
    rescue Errno::EACCES => e
      puts "Permission denied when writing configuration file: #{e.message}".colorize(:red)
      exit 1
    rescue Errno::ENOENT => e
      puts "Directory error when creating configuration: #{e.message}".colorize(:red)
      exit 1
    rescue JSON::GeneratorError => e
      puts "Error generating JSON configuration: #{e.message}".colorize(:red)
      exit 1
    rescue => e
      puts "Unexpected error saving configuration: #{e.class.name} - #{e.message}".colorize(:red)
      exit 1
    end
  end

  # Add this method to your NCRAFT class
  def call_jira_mcp(method_name, params = {})
    # This is a simplified example - you'll need to adapt based on how MCP tools are made available
    begin
      result = send("#{method_name}", **params)
      JSON.parse(result)
    rescue => e
      log("Error calling Jira MCP tool: #{e.message}", :error)
      nil
    end
  end

  private

  def load_config
    unless File.exist?(CONFIG_FILE)
      puts "No configuration found. Please run 'NCRAFT configure' first.".colorize(:red)
      exit 1
    end

    begin
      @config = JSON.parse(File.read(CONFIG_FILE))
    rescue Errno::EACCES => e
      puts "Permission denied when reading configuration file: #{e.message}".colorize(:red)
      exit 1
    rescue JSON::ParserError => e
      puts "Invalid JSON in configuration file: #{e.message}".colorize(:red)
      puts "Please run 'NCRAFT configure' to recreate your configuration.".colorize(:yellow)
      exit 1
    rescue => e
      puts "Unexpected error reading configuration: #{e.class.name} - #{e.message}".colorize(:red)
      exit 1
    end

    # Validate required config values
    missing_keys = []
    %w[jira_token jira_email jira_base_url].each do |key|
      missing_keys << key unless @config.key?(key) && !@config[key].empty?
    end

    unless missing_keys.empty?
      puts "Missing required configuration: #{missing_keys.join(', ')}".colorize(:red)
      puts "Please run 'NCRAFT configure' to set up your configuration.".colorize(:yellow)
      exit 1
    end
  end

  def validate_ticket_format(ticket)
    unless ticket =~ /^[A-Z]+-\d+$/
      log("Error: Invalid ticket ID format. Expected format: PROJECT-123", :error)
      exit 1
    end
  end

  # @return [Logger] Logger instance for the NCRAFT class
  def logger
    @logger ||= begin
      logger = Logger.new(STDOUT)
      logger.formatter = proc do |severity, datetime, progname, msg|
        colors = { 'INFO' => :blue, 'WARN' => :yellow, 'ERROR' => :red, 'DEBUG' => :light_black, 'SUCCESS' => :green }
        color = colors[severity] || :default
        "#{msg.to_s.colorize(color)}
"
      end
      logger
    end
  end

  # Custom logger severity for success messages
  def log_success(message)
    logger.info("✓ #{message}".colorize(:green))
  end

  # Log with rate limiting to avoid flooding console
  def log(message, level = :info)
    @last_log_time ||= {}
    @last_log_time[message] ||= 0
    
    # Only log the same message once per 2 seconds
    if Time.now.to_f - @last_log_time[message] > 2
      case level
      when :info
        logger.info(message)
      when :warn
        logger.warn(message)
      when :error
        logger.error(message)
      when :debug
        logger.debug(message)
      when :success
        log_success(message)
      end
      @last_log_time[message] = Time.now.to_f
    end
  end

  # Validates Jira configuration
  # @return [Boolean] true if configuration is valid, false otherwise
  def validate_jira_config
    required_keys = ['jira_base_url', 'jira_email', 'jira_token']
    
    # Support environment variables
    @config['jira_base_url'] ||= ENV['JIRA_BASE_URL']
    @config['jira_email'] ||= ENV['JIRA_EMAIL']
    @config['jira_token'] ||= ENV['JIRA_API_TOKEN']
    
    missing_keys = required_keys.select { |k| @config[k].nil? || @config[k].to_s.empty? }
    
    unless missing_keys.empty?
      log("Missing Jira configuration: #{missing_keys.join(', ')}", :error)
      return false
    end
    
    true
  end

  # Creates a Faraday HTTP client for Jira API requests
  # @return [Faraday::Connection] Configured HTTP client
  def jira_client
    @jira_client ||= begin
      require 'faraday' unless defined?(Faraday)
      
      Faraday.new(@config['jira_base_url']) do |conn|
        conn.basic_auth(@config['jira_email'], @config['jira_token'])
        conn.headers['Content-Type'] = 'application/json'
        conn.options.timeout = @config['jira_timeout'] || 10
        conn.options.open_timeout = @config['jira_open_timeout'] || 5
      end
    rescue LoadError
      log("Faraday gem not found, falling back to Net::HTTP", :warn)
      nil
    end
  end

  # Executes a block with rate limiting protection
  # @yield Block to execute with rate limiting
  # @return [Object] Result of the block
  def with_rate_limit
    @last_api_call ||= 0
    time_since_last_call = Time.now.to_f - @last_api_call
    min_interval = (@config['jira_min_request_interval'] || 0.5).to_f
    
    if time_since_last_call < min_interval
      sleep(min_interval - time_since_last_call)
    end
    
    @last_api_call = Time.now.to_f
    yield
  end

  # Fetches a Jira ticket using the MCP function
  # @param ticket [String] Jira ticket ID
  # @param fields [String] Comma-separated list of fields to fetch
  # @return [Hash, nil] Ticket data or nil if unsuccessful
  def fetch_via_mcp(ticket, fields)
    log("Attempting to fetch via MCP: #{ticket}", :debug)
    
    begin
      with_rate_limit do
        # Use the mcp4_jira_get_issue tool
        result = call_jira_mcp("get_issue", {
          issue_key: ticket,
          fields: fields
        })
        
        return result if result
      end
    rescue => e
      log("Error calling Jira API via MCP: #{e.message}", :error)
      nil
    end
  end

  def search_jira_issues(jql, limit = 10)
    call_jira_mcp("search", {
      jql: jql,
      limit: limit
    })
  end

  def add_jira_comment(ticket, comment)
    call_jira_mcp("add_comment", {
      issue_key: ticket,
      comment: comment
    })
  end

  def transition_jira_issue(ticket, transition_id)
    call_jira_mcp("transition", {
      issue_key: ticket,
      transition_id: transition_id
    })
  end

  def find_jira_ticket(ticket, fields: "summary,description,status,issuetype,assignee", exit_on_error: false, force_refresh: false)
    log("Getting Jira ticket #{ticket} information...", :info)
    
    # Check cache first
    @jira_cache ||= {}
    if !force_refresh && @jira_cache[ticket] && @config['enable_jira_cache']
      # Cache logic as before
      return @jira_cache[ticket] if cache_is_valid
    end
    
    # Try MCP first
    result = fetch_via_mcp(ticket, fields)
    
    # If MCP failed, try REST API
    result ||= fetch_via_rest_api(ticket, fields) if result.nil?
    
    # Process results
    if result
      processed_result = process_jira_data(result, ticket)
      @jira_cache[ticket] = processed_result if @config['enable_jira_cache']
      return processed_result
    end
    
    # Handle errors
    handle_error("Failed to retrieve ticket data", exit_on_error, ticket)
  end

  def handle_error(message, exit_on_error, ticket)
    log(message, :error)
    
    if exit_on_error
      log("Exiting due to error", :error)
      exit 1
    end
    
    log("Continuing...", :warn)
  end

  def cache_is_valid
    # Implement cache validation logic as before
    true
  end

  # Fetches a Jira ticket using direct REST API
  # @param ticket [String] Jira ticket ID
  # @param fields [String] Comma-separated list of fields to fetch
  # @return [Hash, nil] Ticket data or nil if unsuccessful
  def fetch_via_rest_api(ticket, fields)
    log("Attempting to fetch via REST API: #{ticket}", :debug)
    
    begin
      with_rate_limit do
        if jira_client
          # Use Faraday if available
          response = jira_client.get("rest/api/3/issue/#{ticket}?fields=#{fields}")
          
          if response.status != 200
            log("Error: Jira ticket #{ticket} not found or you don't have access (HTTP #{response.status}).", :error)
            return nil
          end
          
          return JSON.parse(response.body)
        else
          # Fallback to Net::HTTP
          uri = URI.parse("#{@config['jira_base_url']}/rest/api/3/issue/#{ticket}?fields=#{fields}")
          request = Net::HTTP::Get.new(uri)
          request.basic_auth(@config["jira_email"], @config["jira_token"])
          request["Content-Type"] = "application/json"

          http = Net::HTTP.new(uri.hostname, uri.port)
          http.use_ssl = true
          http.read_timeout = @config['jira_timeout'] || 10
          http.open_timeout = @config['jira_open_timeout'] || 5

          response = http.request(request)

          if response.code != "200"
            log("Error: Jira ticket #{ticket} not found or you don't have access (HTTP #{response.code}).", :error)
            return nil
          end

          return JSON.parse(response.body)
        end
      end
    rescue URI::InvalidURIError => e
      log("Invalid Jira URL: #{e.message}", :error)
      nil
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      log("Network timeout when connecting to Jira: #{e.message}", :error)
      nil
    rescue SocketError => e
      log("Network error connecting to Jira: #{e.message}", :error)
      nil
    rescue JSON::ParserError => e
      log("Error parsing Jira response: #{e.message}", :error)
      nil
    rescue => e
      log("Unexpected error getting Jira ticket: #{e.class.name} - #{e.message}", :error)
      nil
    end
  end

  # Process the raw Jira data into a standardized format
  # @param data [Hash] Raw Jira data
  # @param ticket [String] Ticket ID
  # @return [Hash] Standardized ticket information
  def process_jira_data(data, ticket)
    return nil unless data && data["fields"]
    
    fields = data["fields"]
    
    summary = fields["summary"]
    description = fields["description"].to_s
    status = fields["status"]["name"] rescue "Unknown"
    ticket_type = fields["issuetype"]["name"] rescue "Unknown"
    assignee = fields["assignee"] ? fields["assignee"]["displayName"] : "Unassigned"
    
    {
      "summary" => summary,
      "description" => description,
      "status" => status,
      "type" => ticket_type,
      "assignee" => assignee,
      "key" => ticket,
      "fetched_at" => Time.now
    }
  end

  # @param ticket [String] The Jira ticket ID (e.g., "OMNI-3130")
  # @param fields [String] Comma-separated list of fields to fetch
  # @param exit_on_error [Boolean] Whether to exit the program on error
  # @param force_refresh [Boolean] Whether to bypass the cache
  # @return [Hash] Ticket information or error details
  def get_jira_ticket(ticket, fields: "summary,description,status,issuetype,assignee", exit_on_error: false, force_refresh: false)
    log("Getting Jira ticket #{ticket} information...", :info)
    
    # Initialize cache if needed
    @jira_cache ||= {}
    
    # Return from cache if available and not forcing refresh
    if !force_refresh && @jira_cache[ticket] && @config['enable_jira_cache']
      cache_age = Time.now.to_f - (@jira_cache[ticket]['fetched_at'] || Time.now).to_f
      cache_ttl = (@config['jira_cache_ttl'] || 300).to_f # Default 5 minutes
      
      if cache_age < cache_ttl
        log("Using cached data for #{ticket} (#{cache_age.round(1)}s old)", :debug)
        return @jira_cache[ticket]
      end
    end
    
    # Validate configuration before proceeding
    unless validate_jira_config
      error_msg = "Cannot fetch Jira ticket: Invalid configuration"
      log(error_msg, :error)
      exit 1 if exit_on_error
      return { "error" => error_msg, "key" => ticket }
    end
    
    begin
      # Try MCP first, then fallback to REST API
      data = nil
      
      if respond_to?(:jira_get_issue)
        data = fetch_via_mcp(ticket, fields)
      end
      
      # Fallback to REST API if MCP fails
      if data.nil?
        data = fetch_via_rest_api(ticket, fields)
      end
      
      # Process the data if we have it
      if data
        result = process_jira_data(data, ticket)
        
        if result
          log("Found ticket: #{ticket} - #{result['summary']}", :success)
          log("Type: #{result['type']}", :info)
          log("Status: #{result['status']}", :info)
          log("Assignee: #{result['assignee']}", :info)
          
          # Cache the result if caching is enabled
          @jira_cache[ticket] = result if @config['enable_jira_cache']
          
          return result
        end
      end
      
      # If we get here, both methods failed
      error_msg = "Failed to retrieve ticket data using both MCP and REST API"
      log(error_msg, :error)
      exit 1 if exit_on_error
      return { "error" => error_msg, "key" => ticket }
      
    rescue => e
      error_msg = "Error fetching Jira ticket: #{e.message}"
      log(error_msg, :error)
      exit 1 if exit_on_error
      return { "error" => error_msg, "key" => ticket }
    end
  end

  def create_branch(ticket, description, base_branch)
    log("Creating branch for #{ticket}...", :info)

    # Make the branch name safe
    safe_description = description.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/-+$/, '').gsub(/^-+/, '')
    branch_name = "#{ticket.downcase}/#{safe_description}"

    begin
      # Check if we're in a git repo
      stdout, stderr, status = Open3.capture3("git rev-parse --is-inside-work-tree")
      unless status.success?
        puts "Error: Not in a git repository. Please navigate to a git repository.".colorize(:red)
        exit 1
      end

      # Check if branch already exists
      stdout, stderr, status = Open3.capture3("git show-ref --verify --quiet refs/heads/#{branch_name}")
      if status.success?
        puts "Branch '#{branch_name}' already exists. Using existing branch.".colorize(:yellow)
        return branch_name
      end

      # Make sure base branch exists and is up to date
      stdout, stderr, status = Open3.capture3("git show-ref --verify --quiet refs/heads/#{base_branch}")
      unless status.success?
        # Try to fetch it from origin
        puts "Base branch '#{base_branch}' not found locally. Attempting to fetch from origin...".colorize(:yellow)
        fetch_stdout, fetch_stderr, fetch_status = Open3.capture3("git fetch origin #{base_branch}:#{base_branch}")
        
        unless fetch_status.success?
          puts "Error fetching base branch '#{base_branch}' from origin: #{fetch_stderr}".colorize(:red)
          exit 1
        end

        # Check again
        stdout, stderr, status = Open3.capture3("git show-ref --verify --quiet refs/heads/#{base_branch}")
        unless status.success?
          puts "Error: Base branch '#{base_branch}' not found locally or in origin.".colorize(:red)
          exit 1
        end
      end

      # Create the new branch
      checkout_stdout, checkout_stderr, checkout_status = Open3.capture3("git checkout #{base_branch}")
      unless checkout_status.success?
        puts "Error checking out base branch '#{base_branch}': #{checkout_stderr}".colorize(:red)
        exit 1
      end

      pull_stdout, pull_stderr, pull_status = Open3.capture3("git pull origin #{base_branch}")
      unless pull_status.success?
        puts "Warning: Failed to pull latest changes from origin/#{base_branch}: #{pull_stderr}".colorize(:yellow)
        puts "Continuing with local version of #{base_branch}...".colorize(:yellow)
      end

      branch_stdout, branch_stderr, branch_status = Open3.capture3("git checkout -b #{branch_name}")
      unless branch_status.success?
        puts "Error creating branch '#{branch_name}': #{branch_stderr}".colorize(:red)
        exit 1
      end

      puts "✓ Created and switched to branch '#{branch_name}'".colorize(:green)
      branch_name
    rescue Errno::ENOENT => e
      puts "Git command not found: #{e.message}".colorize(:red)
      exit 1
    rescue => e
      puts "Unexpected error creating git branch: #{e.class.name} - #{e.message}".colorize(:red)
      exit 1
    end
  end

  def read_pr_template
    # Try to use read_file MCP function if available
    if respond_to?(:read_file)
      begin
        return read_file(path: ".github/PULL_REQUEST_TEMPLATE.md")
      rescue => e
        begin
          return read_file(path: "PULL_REQUEST_TEMPLATE.md")
        rescue => e
          return nil
        end
      end
    else
      # Fallback to standard File.read
      template_path = ".github/PULL_REQUEST_TEMPLATE.md"
      template_path = "PULL_REQUEST_TEMPLATE.md" unless File.exist?(template_path)

      return File.read(template_path) if File.exist?(template_path)
      return nil
    end
  end

  def remove_html_comments(text)
    # Remove HTML comments
    text.gsub(/<!--.*?-->/m, '')
  end

  def get_git_diff(base_branch)
    # Get the diff between current branch and base branch
    stdout, stderr, status = Open3.capture3("git diff #{base_branch}...HEAD")

    return stdout if status.success?

    puts "Error getting git diff: #{stderr}".colorize(:red)
    return ""
  end

  def get_changed_files
    # Get list of changed files
    stdout, stderr, status = Open3.capture3("git diff --name-only HEAD")

    return stdout.split("\n") if status.success?

    puts "Error getting changed files: #{stderr}".colorize(:red)
    return []
  end

  def extract_commit_messages
    # Get commit messages
    stdout, stderr, status = Open3.capture3("git log --pretty=format:'%s' HEAD...$(git merge-base HEAD origin/main)")

    return stdout.split("\n") if status.success?

    puts "Error getting commit messages: #{stderr}".colorize(:red)
    return []
  end

  def get_summary_of_changes(diff, changed_files, ticket_info)
    # Generate summary based on the diff and changed files
    summary = "Implements #{ticket_info['key']}: #{ticket_info['summary']}\n\n"

    # Add key file changes
    if changed_files.any?
      summary += "Key files modified:\n"
      changed_files.first(5).each do |file|
        summary += "- #{file}\n"
      end

      if changed_files.size > 5
        summary += "- ... and #{changed_files.size - 5} more files\n"
      end

      summary += "\n"
    end

    # Try to extract key changes from diff
    changes = []

    # Look for method definitions
    diff.scan(/^\+\s*def\s+(\w+)/).each do |match|
      changes << "Added method `#{match[0]}`"
    end

    # Look for class definitions
    diff.scan(/^\+\s*class\s+(\w+)/).each do |match|
      changes << "Added class `#{match[0]}`"
    end

    # Look for migrations
    changed_files.each do |file|
      if file =~ /db\/migrate/
        changes << "Added database migration: #{File.basename(file)}"
      end
    end

    # Look for specs/tests
    spec_count = changed_files.count { |f| f =~ /_spec\.rb$|_test\.rb$/ }
    if spec_count > 0
      changes << "Added/updated #{spec_count} test files"
    end

    # Add extracted changes
    if changes.any?
      summary += "Key changes:\n"
      changes.uniq.first(5).each do |change|
        summary += "- #{change}\n"
      end
    end

    summary
  end

  def extract_breaking_changes(diff, commit_messages)
    # Look for breaking changes in diff and commit messages
    breaking_changes = []

    # Check commit messages for breaking change indicators
    commit_messages.each do |msg|
      if msg =~ /BREAKING CHANGE/i || msg =~ /!:/
        breaking_changes << msg.gsub(/.*BREAKING CHANGE:\s*/i, '')
      end
    end

    # Look for removed methods
    diff.scan(/^-\s*def\s+(\w+)/).each do |match|
      if diff !~ /^\+\s*def\s+#{match[0]}/
        breaking_changes << "Removed method `#{match[0]}`"
      end
    end

    # Look for removed classes
    diff.scan(/^-\s*class\s+(\w+)/).each do |match|
      if diff !~ /^\+\s*class\s+#{match[0]}/
        breaking_changes << "Removed class `#{match[0]}`"
      end
    end

    # Look for schema changes
    diff.scan(/^-\s*t\.(\w+)\s+"(\w+)"/).each do |match|
      breaking_changes << "Removed database column `#{match[1]}` of type `#{match[0]}`"
    end

    if breaking_changes.any?
      return breaking_changes.uniq.join("\n")
    else
      return "None"
    end
  end

  def generate_testing_instructions(changed_files)
    testing_instructions = "Author\n\n"

    # Generate testing instructions based on changed files
    test_suggestions = []

    # Check for model changes
    model_files = changed_files.select { |f| f =~ /app\/models/ }
    if model_files.any?
      test_suggestions << "- Verify model validations and associations work as expected"
    end

    # Check for controller changes
    controller_files = changed_files.select { |f| f =~ /app\/controllers/ }
    if controller_files.any?
      test_suggestions << "- Test all controller actions, including error cases"
    end

    # Check for view changes
    view_files = changed_files.select { |f| f =~ /app\/views/ }
    if view_files.any?
      test_suggestions << "- Verify UI displays correctly in different browsers and screen sizes"
    end

    # Check for job changes
    job_files = changed_files.select { |f| f =~ /app\/jobs/ }
    if job_files.any?
      test_suggestions << "- Verify background jobs execute correctly"
    end

    # Check for migration changes
    migration_files = changed_files.select { |f| f =~ /db\/migrate/ }
    if migration_files.any?
      test_suggestions << "- Verify migrations run without errors and can be rolled back"
    end

    # Add test suggestions
    if test_suggestions.any?
      testing_instructions += "Suggested testing steps:\n"
      test_suggestions.each do |suggestion|
        testing_instructions += "#{suggestion}\n"
      end
    end

    testing_instructions
  end

  def clean_and_format_section(text)
    # Clean up whitespace and ensure proper formatting
    clean = text.gsub(/\n{3,}/, "\n\n") # Replace multiple blank lines with just two
    clean = clean.strip # Remove leading/trailing whitespace
    clean
  end

  def generate_pr_draft(ticket, ticket_info, branch_name, base_branch)
    # Get the diff to analyze changes
    diff = get_git_diff(base_branch)
    changed_files = get_changed_files
    commit_messages = extract_commit_messages

    # Get template content
    template = read_pr_template

    if !template
      puts "Could not find PR template. Using default template.".colorize(:red)
      template = <<~EOT
        ## Issue Link

        <!-- Include a working link to the Jira ticket(s) that this PR is related to -->

        ## Summary of Changes

        <!-- Describe all the proposed changes included in this PR -->

        ## Testing Performed By

        <!-- Tag who validated the changes work as described and don't break existing functionality -->

        ## Breaking Changes

        <!-- Include any breaking changes or manual upgrade steps required to adopt, if applicable. -->
      EOT
    end

    # Generate the PR title
    pr_title = "#{ticket_info['key']}: #{ticket_info['summary']}"

    # Replace comment sections with actual content

    # Replace issue link
    issue_link = "#{@config['jira_base_url']}/browse/#{ticket_info['key']}"
    template = template.gsub(
      /<!--\s*Include a working link to the Jira ticket\(s\) that this PR is related to\s*-->/,
      issue_link
    )

    # Replace summary of changes
    summary_of_changes = get_summary_of_changes(diff, changed_files, ticket_info)
    template = template.gsub(
      /<!--\s*Describe all the proposed changes included in this PR\s*-->/,
      summary_of_changes
    )

    # Replace testing performed by
    testing_instructions = generate_testing_instructions(changed_files)
    template = template.gsub(
      /<!--\s*Tag who validated the changes work as described and don't break existing functionality\s*-->/,
      testing_instructions
    )

    # Replace breaking changes
    breaking_changes = extract_breaking_changes(diff, commit_messages)
    template = template.gsub(
      /<!--\s*Include any breaking changes or manual upgrade steps required to adopt, if applicable\.\s*-->/,
      breaking_changes
    )

    # Replace PR title
    template = template.gsub(
      /<!--\s*PR title should also start with the Jira ticket number\(s\)\s*-->/,
      "PR title: #{pr_title}"
    )

    # Remove any remaining HTML comments
    template = remove_html_comments(template)

    # Clean up whitespace and ensure proper formatting
    sections = template.split(/^##\s+/)

    formatted_sections = []
    sections.each do |section|
      next if section.strip.empty?

      lines = section.split("\n")
      section_title = lines.shift # Remove the section title line
      section_content = lines.join("\n")

      # Clean up section content
      section_content = clean_and_format_section(section_content)

      # Add section back with proper formatting
      formatted_sections << "## #{section_title}\n\n#{section_content}"
    end

    # Join sections back together
    formatted_content = formatted_sections.join("\n\n")

    # Save to PR_Draft.md
    fname = "#{PR_DRAFT_FILE.to_s}_#{ticket}.md"
    File.write(fname, formatted_content)

    puts "✓ Saved PR draft as #{fname}".colorize(:green)

    formatted_content
  end

  def show_banner()
    puts ""
    puts "  ███╗   ██╗ ██████╗██████╗  █████╗ ███████╗████████╗".colorize(:blue)
    puts "  ████╗  ██║██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝".colorize(:blue)
    puts "  ██╔██╗ ██║██║     ██████╔╝███████║█████╗     ██║   ".colorize(:blue)
    puts "  ██║╚██╗██║██║     ██╔══██╗██╔══██║██╔══╝     ██║   ".colorize(:blue)
    puts "  ██║ ╚████║╚██████╗██║  ██║██║  ██║██║        ██║   ".colorize(:blue)
    puts "  ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝   ".colorize(:blue)
    puts "  nCino Code Review Automation Framework Tool".colorize(:green)
    puts "  Version 1.0.0\n".colorize(:yellow)
  end
end

# If running as a script
if __FILE__ == $0
  NCRAFT.start(ARGV)
end
