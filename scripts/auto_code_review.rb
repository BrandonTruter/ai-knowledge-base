#!/usr/bin/env ruby

# AutoCodeReview - Automated code review tool for Ruby, Rails, JavaScript, Vue.js, and GraphQL
# with Git branch comparison and PR draft generation
#
# Run with: ruby auto_code_review.rb [options]

require 'json'
require 'find'
require 'fileutils'
require 'open3'
require 'optparse'
require 'date'
require 'uri'

# Install required gems if not present
begin
  require 'colorize'
rescue LoadError
  puts "Installing required gem: colorize"
  system("gem install colorize")
  require 'colorize'
end

# Configuration
CONFIG = {
  ruby_extensions: ['.rb', '.rake', '.gemspec'],
  js_extensions: ['.js', '.jsx', '.vue'],
  graphql_extensions: ['.graphql', '.gql'],
  ignore_dirs: ['node_modules', 'vendor', 'tmp', 'log', 'public', 'dist', 'coverage', '.git'],
  ignore_files: [],
  max_line_length: 100,
  max_method_length: 25, # lines
  max_file_size: 300, # lines
  default_repo_url: 'ncino/aws-omni-channel',
  default_base_branch: 'origin/develop',
  pr_template_paths: [
    'PULL_REQUEST_TEMPLATE.md',
    '.github/PULL_REQUEST_TEMPLATE.md',
    '.github/pull_request_template.md'
  ],
  # nCino specific configurations
  ncino: {
    accessibility_checks: true,
    naming_convention_checks: true,
    ruby_style_checks: true,
    js_style_checks: true,
    database_best_practices: true
  }
}

# Issue tracking
ISSUES = {
  critical: [],
  warnings: [],
  suggestions: []
}

# Parse command line options
def parse_options
  options = {
    repo_url: nil,
    base_branch: nil,
    compare_branch: nil,
    install_hook: false,
    verbose: false
  }

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

    opts.on("--repo URL", "GitHub repository URL") do |url|
      options[:repo_url] = url
    end

    opts.on("--base BRANCH", "Base branch to compare against") do |branch|
      options[:base_branch] = branch
    end

    opts.on("--compare BRANCH", "Branch with changes to review") do |branch|
      options[:compare_branch] = branch
    end

    opts.on("--install-hook", "Install git pre-commit hook") do
      options[:install_hook] = true
    end

    opts.on("-v", "--verbose", "Run with verbose output") do
      options[:verbose] = true
    end

    opts.on("-h", "--help", "Show this help message") do
      puts opts
      exit
    end
  end

  opt_parser.parse!

  options
end

# Execute a git command and return the output
def git_command(cmd)
  output, status = Open3.capture2e("git #{cmd}")
  if status.success?
    return output.strip
  else
    puts "Error executing git command: #{cmd}".red
    puts output
    return nil
  end
end

# Check if we're in a git repository
def in_git_repo?
  git_command("rev-parse --is-inside-work-tree") == "true"
end

# Get the current branch name
def current_branch
  git_command("rev-parse --abbrev-ref HEAD")
end

# Prompt for user input with default value
def prompt(message, default)
  print "#{message} [#{default}]: "
  input = gets.chomp.strip
  input.empty? ? default : input
end

# Validate GitHub URL
def valid_github_url?(url)
  return false if url.nil? || url.empty?
  
  begin
    uri = URI.parse(url)
    return uri.host == "github.com" && !uri.path.empty?
  rescue URI::InvalidURIError
    return false
  end
end

# Get files changed between two branches
def get_changed_files(base_branch, compare_branch)
  changed_files = git_command("diff --name-only #{base_branch}..#{compare_branch}")
  return changed_files.nil? ? [] : changed_files.split("\n")
end

# Get commit messages between two branches
def get_commit_messages(base_branch, compare_branch)
  commits = git_command("log --pretty=format:'%h %s' #{base_branch}..#{compare_branch}")
  return commits.nil? ? [] : commits.split("\n")
end

# Find PR template
def find_pr_template
  CONFIG[:pr_template_paths].each do |path|
    return path if File.exist?(path)
  end
  
  # Check for template in current directory and subdirectories
  template_path = nil
  Find.find('.') do |path|
    if File.basename(path).downcase == 'pull_request_template.md'
      template_path = path
      break
    end
  end
  
  template_path
end

# Helper function to check if a command exists
def command_exists?(command)
  system("which #{command} > /dev/null 2>&1")
end

# Generate PR draft from template
def generate_pr_draft(base_branch, compare_branch, changed_files)
  puts "\n" + ' GENERATING PR DRAFT '.on_green.black

  # Find PR template
  template_path = find_pr_template
  
  if template_path.nil?
    puts "PR template not found. Using default template.".yellow
    return generate_default_pr_draft(base_branch, compare_branch, changed_files)
  end
  
  template = File.read(template_path)
  pr_draft = template.dup
  
  # Get commit information
  commit_messages = get_commit_messages(base_branch, compare_branch)
  
  # Extract Jira ticket numbers from commit messages
  jira_tickets = extract_jira_tickets(commit_messages)
  
  # Extract semantic commit types
  semantic_commits = extract_semantic_commits(commit_messages)
  
  # Create summary of changes
  summary = generate_summary(changed_files, commit_messages, semantic_commits, jira_tickets)
  
  # Add code review findings
  review_summary = generate_review_summary()
  summary += "\n" + review_summary
  
  # Replace placeholders in template
  if jira_tickets.any?
    ticket_links = jira_tickets.map { |ticket| 
      "https://jira.example.com/browse/#{ticket}" 
    }.join("\n")
    
    pr_draft.gsub!(/<!--\s*Include a working link to the Jira ticket\(s\) that this PR is related to\s*-->/, 
                  ticket_links)
  end
  
  pr_draft.gsub!(/<!--\s*Describe all the proposed changes included in this PR\s*-->/, summary)
  
  # Set generic values for other fields
  pr_draft.gsub!(/<!--\s*Tag who validated the changes work as described and don't break existing functionality\s*-->/, 
                "@reviewer")
  
  pr_draft.gsub!(/<!--\s*Include any breaking changes or manual upgrade steps required to adopt, if applicable.\s*-->/, 
                "No breaking changes.")
  
  # Create PR title suggestion
  title_suggestion = generate_pr_title(jira_tickets, semantic_commits, commit_messages)
  
  # Write PR draft to file
  pr_filename = "PULL_REQUEST_DRAFT.md"
  File.write(pr_filename, pr_draft)
  
  puts "\nPR draft saved to #{pr_filename}".green
  puts "Suggested PR title: #{title_suggestion}".green
  
  pr_filename
end

# Extract Jira ticket numbers from commit messages
def extract_jira_tickets(commit_messages)
  jira_tickets = []
  
  commit_messages.each do |msg|
    # Match common Jira ticket patterns like ABC-123
    tickets = msg.scan(/([A-Z]+-\d+)/)
    jira_tickets.concat(tickets.flatten) if tickets.any?
  end
  
  jira_tickets.uniq
end

# Extract semantic commits from commit messages
def extract_semantic_commits(commit_messages)
  semantic_types = {}
  
  commit_messages.each do |msg|
    if msg =~ /^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.*?\))?:\s+(.*)$/
      type = $1
      scope = $2
      description = $3
      
      semantic_types[type] ||= []
      semantic_types[type] << description
    end
  end
  
  semantic_types
end

# Generate summary of changes
def generate_summary(changed_files, commit_messages, semantic_commits, jira_tickets)
  summary = "## Summary of Changes\n\n"
  
  # Group changed files by type
  ruby_files = changed_files.select { |f| CONFIG[:ruby_extensions].include?(File.extname(f)) }
  js_files = changed_files.select { |f| CONFIG[:js_extensions].include?(File.extname(f)) }
  graphql_files = changed_files.select { |f| CONFIG[:graphql_extensions].include?(File.extname(f)) }
  other_files = changed_files - ruby_files - js_files - graphql_files
  
  summary += "This PR includes changes to #{changed_files.size} files:\n"
  summary += "- #{ruby_files.size} Ruby files\n" if ruby_files.any?
  summary += "- #{js_files.size} JavaScript/Vue files\n" if js_files.any?
  summary += "- #{graphql_files.size} GraphQL files\n" if graphql_files.any?
  summary += "- #{other_files.size} other files\n" if other_files.any?
  summary += "\n"
  
  # Add semantic commit information
  if semantic_commits.any?
    summary += "### Changes by Type\n\n"
    
    semantic_commits.each do |type, descriptions|
      type_name = case type
                   when 'feat' then 'Features'
                   when 'fix' then 'Bug Fixes'
                   when 'docs' then 'Documentation'
                   when 'style' then 'Style Improvements'
                   when 'refactor' then 'Code Refactoring'
                   when 'perf' then 'Performance Improvements'
                   when 'test' then 'Tests'
                   when 'build' then 'Build System'
                   when 'ci' then 'CI Pipeline'
                   when 'chore' then 'Chores'
                   when 'revert' then 'Reverts'
                   else type.capitalize
                 end
      
      summary += "#### #{type_name}\n"
      descriptions.each do |desc|
        summary += "- #{desc}\n"
      end
      summary += "\n"
    end
  else
    # If no semantic commits found, list regular commits
    summary += "### Commits\n\n"
    commit_messages.each do |msg|
      summary += "- #{msg}\n"
    end
    summary += "\n"
  end
  
  summary
end

# Generate review summary
def generate_review_summary
  summary = "### Code Review Summary\n\n"
  
  summary += "- #{ISSUES[:critical].length} critical issues\n"
  summary += "- #{ISSUES[:warnings].length} warnings\n"
  summary += "- #{ISSUES[:suggestions].length} suggestions\n\n"
  
  # Add nCino-specific review notes based on guidelines
  summary += "### nCino Guidelines Review\n\n"
  summary += "Per nCino's code review guidelines, this automated review has checked for:\n\n"
  summary += "- Potential N+1 queries and database operations without transactions\n"
  summary += "- Vue.js components without proper key attributes and prop validations\n"
  summary += "- Controller actions that may be too complex ('fat controllers')\n"
  summary += "- Accessibility concerns like missing ARIA attributes\n"
  summary += "- Potential security issues\n\n"
  
  if ISSUES[:critical].any?
    summary += "#### Critical Issues to Fix\n\n"
    ISSUES[:critical].each do |issue|
      line_info = issue[:line] ? ":#{issue[:line]}" : ''
      summary += "- #{issue[:file]}#{line_info} - #{issue[:message]}\n"
      summary += "  - _Suggestion: #{issue[:suggestion]}_\n"
    end
    summary += "\n"
  end
  
  if ISSUES[:warnings].any?
    # Show top 5 warnings to keep the summary concise
    top_warnings = ISSUES[:warnings].take(5)
    summary += "#### Top Warnings\n\n"
    top_warnings.each do |issue|
      line_info = issue[:line] ? ":#{issue[:line]}" : ''
      summary += "- #{issue[:file]}#{line_info} - #{issue[:message]}\n"
      summary += "  - _Suggestion: #{issue[:suggestion]}_\n"
    end
    
    if ISSUES[:warnings].length > 5
      summary += "- ... and #{ISSUES[:warnings].length - 5} more warnings\n"
    end
    summary += "\n"
  end
  
  # Add nCino's PR checklist for reviewers
  summary += "### Reviewer Checklist\n\n"
  summary += "- [ ] Code conforms to nCino's [coding standards and style guidance](https://github.com/ncino/ncino-development-guide)\n"
  summary += "- [ ] The solution uses appropriate architecture and patterns\n"
  summary += "- [ ] Tests assert on enough scenarios (happy path, error conditions, etc.)\n"
  summary += "- [ ] User-facing text is properly prepared or approved by a Technical Communicator\n"
  summary += "- [ ] Any added/modified files are in the correct directory structure\n"
  summary += "- [ ] Code is [encryption compliant](https://ncinodev.atlassian.net/wiki/spaces/DEV/pages/131941255/Platform+Encryption+Support+-+Development+Guide)\n"
  summary += "- [ ] Accessibility standards are met (keyboard navigation, screen reader compatibility)\n\n"
  
  summary
end

# Generate PR title
def generate_pr_title(jira_tickets, semantic_commits, commit_messages)
  title = ""
  
  # Add Jira ticket reference
  if jira_tickets.any?
    title = "#{jira_tickets.first}: "
  end
  
  # Try to create a meaningful title from semantic commits
  if semantic_commits.any?
    key_changes = []
    ['feat', 'fix'].each do |important_type|
      if semantic_commits[important_type] && semantic_commits[important_type].any?
        key_changes << "#{important_type}: #{semantic_commits[important_type].first}"
      end
    end
    
    if key_changes.any?
      title += key_changes.first
    else
      # Use the first semantic commit of any type
      first_type = semantic_commits.keys.first
      title += "#{first_type}: #{semantic_commits[first_type].first}"
    end
  elsif commit_messages.any?
    # Use first commit message if no semantic commits
    title += commit_messages.first.sub(/^[a-f0-9]+ /, '') # Remove commit hash
  else
    title += "Changes"
  end
  
  title
end

# Generate a default PR template if none exists
def generate_default_pr_draft(base_branch, compare_branch, changed_files)
  # Extract Jira ticket numbers and semantic commits
  commit_messages = get_commit_messages(base_branch, compare_branch)
  jira_tickets = extract_jira_tickets(commit_messages)
  semantic_commits = extract_semantic_commits(commit_messages)
  
  # Create summary
  summary = generate_summary(changed_files, commit_messages, semantic_commits, jira_tickets)
  review_summary = generate_review_summary()
  
  jira_ticket = jira_tickets.first || "TICKET-NUMBER"
  pr_title = generate_pr_title(jira_tickets, semantic_commits, commit_messages)
  
  pr_draft = <<~PR
    # Pull Request: #{pr_title}
    
    ## Issue Link
    #{jira_tickets.any? ? jira_tickets.map { |t| "https://jira.example.com/browse/#{t}" }.join("\n") : "<!-- Add Jira ticket link -->"}
    
    ## Summary of Changes
    #{summary}
    
    ## Code Review Results
    #{review_summary}
    
    ## Testing Performed By
    @reviewer
    
    ## Breaking Changes
    None.
    
    ## Guidelines
    - [ ] PR follows the guidelines in CONTRIBUTING.md
    - [ ] PR includes semantic commit(s)
    - [ ] PR has been tested in appropriate environments
  PR
  
  # Write PR draft to file
  pr_filename = "PULL_REQUEST_DRAFT.md"
  File.write(pr_filename, pr_draft)
  
  puts "\nPR draft saved to #{pr_filename}".green
  puts "Suggested PR title: #{pr_title}".green
  
  pr_filename
end

# Process changed files for code review
def review_files(files)
  files.each do |file|
    begin
      content = File.read(file)
      ext = File.extname(file)
      
      # Basic checks for all files
      check_file_size(file, content)
      check_line_length(file, content)
      
      # Language-specific checks
      if CONFIG[:ruby_extensions].include?(ext)
        analyze_ruby_file(file, content)
      elsif CONFIG[:js_extensions].include?(ext)
        analyze_js_file(file, content)
        analyze_vue_file(file, content) if ext == '.vue'
      elsif CONFIG[:graphql_extensions].include?(ext)
        analyze_graphql_file(file, content)
      end
    rescue => e
      puts "Error analyzing file #{file}: #{e.message}".red
    end
  end
end

# Basic checks
def check_file_size(file, content)
  lines = content.split("\n")
  if lines.length > CONFIG[:max_file_size]
    ISSUES[:warnings] << {
      file: file,
      line: nil,
      message: "File has #{lines.length} lines (max recommended: #{CONFIG[:max_file_size]})",
      suggestion: 'Consider splitting this file into smaller, more focused modules'
    }
  end
end

def check_line_length(file, content)
  lines = content.split("\n")
  lines.each_with_index do |line, index|
    if line.length > CONFIG[:max_line_length]
      ISSUES[:suggestions] << {
        file: file,
        line: index + 1,
        message: "Line exceeds #{CONFIG[:max_line_length]} characters",
        suggestion: 'Break this line into multiple lines for better readability'
      }
    end
  end
end

# Ruby specific analysis
def analyze_ruby_file(file, content)
  lines = content.split("\n")
  
  # Check for Rails model without validations
  if file.include?('/models/') && !file.include?('_spec.rb') && !file.include?('/concerns/')
    if !content.include?('validates ') && !content.include?('validate ')
      ISSUES[:warnings] << {
        file: file,
        line: nil,
        message: 'Rails model may be missing validations',
        suggestion: 'Consider adding appropriate validations to ensure data integrity'
      }
    end
    
    # Check models for complex methods (Fat models)
    check_method_complexity(file, content)
  end
  
  # Check for Rails controller with fat actions
  if file.include?('/controllers/') && !file.include?('_spec.rb')
    content.scan(/def\s+(\w+)/) do |match|
      def_name = match[0]
      start_index = content.index(/def\s+#{def_name}/)
      next unless start_index
      
      # Find the end of the method
      end_index = nil
      depth = 0
      lines_from_start = content[start_index..-1].split("\n")
      
      lines_from_start.each_with_index do |line, idx|
        depth += 1 if line =~ /(\s|^)(if|unless|do|def|class|module|begin|case)(\s|$)/
        depth -= 1 if line =~ /(\s|^)end(\s|$)/
        
        if depth == 0
          end_index = start_index + content[start_index..-1].split("\n")[0..idx].join("\n").length
          break
        end
      end
      
      next unless end_index
      
      method_content = content[start_index..end_index]
      method_lines = method_content.split("\n").length
      
      if method_lines > CONFIG[:max_method_length]
        ISSUES[:warnings] << {
          file: file,
          line: content[0...start_index].split("\n").length + 1,
          message: "Action '#{def_name}' has #{method_lines} lines (max recommended: #{CONFIG[:max_method_length]})",
          suggestion: 'Extract logic to service objects or model methods to keep controllers skinny'
        }
      end
    end
  end
  
  # Check for RESTful controllers
  if file.include?('/controllers/') && !file.include?('_spec.rb')
    restful_actions = ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy']
    non_restful_actions = []
    
    content.scan(/def\s+(\w+)/) do |match|
      action_name = match[0]
      unless restful_actions.include?(action_name) || action_name.start_with?('_')
        non_restful_actions << action_name
      end
    end
    
    if non_restful_actions.any?
      ISSUES[:suggestions] << {
        file: file,
        line: nil,
        message: "Controller has non-RESTful actions: #{non_restful_actions.join(', ')}",
        suggestion: 'Consider using RESTful actions or moving custom logic to service objects'
      }
    end
  end
  
  # Check for n+1 query potential
  if content.include?('.each') && (content.include?('.find') || content.include?('.where'))
    ISSUES[:warnings] << {
      file: file,
      line: nil,
      message: 'Potential N+1 query detected',
      suggestion: 'Use includes(), eager_load(), or preload() to avoid N+1 queries'
    }
  end
  
  # Check for missing indexes in migrations
  if file.include?('/migrate/') && content.include?('create_table') && !content.include?('add_index')
    ISSUES[:warnings] << {
      file: file, 
      line: nil,
      message: 'Migration creates a table without adding indexes',
      suggestion: 'Consider adding indexes for foreign keys and frequently queried columns'
    }
  end
  
  # Check for application code in migrations
  if file.include?('/migrate/') && (content.include?('ActiveRecord::Base.transaction') || 
                                    content.include?('find_each') || 
                                    content.include?('create!'))
    ISSUES[:warnings] << {
      file: file,
      line: nil, 
      message: 'Migration may contain application code',
      suggestion: 'Keep application code out of migrations; use SQL for simple changes'
    }
  end
  
  # Check for missing database transactions
  if file.include?('/controllers/') && 
     (content.include?('save') || content.include?('update') || content.include?('destroy')) &&
     !content.include?('transaction')
    ISSUES[:warnings] << {
      file: file,
      line: nil,
      message: 'Controller performs database operations without a transaction',
      suggestion: 'Consider wrapping related database operations in ActiveRecord::Base.transaction blocks'
    }
  end
  
  # Check for missing error handling
  if file.include?('/controllers/') && 
     (content.include?('save') || content.include?('update') || content.include?('create')) &&
     !content.include?('if') && !content.include?('rescue')
    ISSUES[:warnings] << {
      file: file,
      line: nil,
      message: 'Controller operations missing error handling',
      suggestion: 'Add proper error handling for database operations using if/else or rescue blocks'
    }
  end
  
  # Check Ruby naming conventions
  check_ruby_naming_conventions(file, content)
end

# Check method complexity
def check_method_complexity(file, content)
  method_complexities = []
  
  content.scan(/def\s+(\w+)/) do |match|
    method_name = match[0]
    start_index = content.index(/def\s+#{method_name}/)
    next unless start_index
    
    # Find the end of the method
    end_index = nil
    depth = 0
    lines_from_start = content[start_index..-1].split("\n")
    
    lines_from_start.each_with_index do |line, idx|
      depth += 1 if line =~ /(\s|^)(if|unless|do|def|class|module|begin|case)(\s|$)/
      depth -= 1 if line =~ /(\s|^)end(\s|$)/
      
      if depth == 0
        end_index = start_index + content[start_index..-1].split("\n")[0..idx].join("\n").length
        break
      end
    end
    
    next unless end_index
    
    method_content = content[start_index..end_index]
    
    # Calculate cyclomatic complexity (rough approximation)
    complexity = 1 # Base complexity
    complexity += method_content.scan(/if|unless|while|until|for|when|rescue/).length
    complexity += method_content.scan(/&&|\|\|/).length
    
    if complexity > 10
      method_complexities << {
        name: method_name,
        complexity: complexity,
        line: content[0...start_index].split("\n").length + 1
      }
    end
  end
  
  if method_complexities.any?
    complex_methods = method_complexities.map { |m| "#{m[:name]} (complexity: #{m[:complexity]})" }.join(', ')
    
    ISSUES[:warnings] << {
      file: file,
      line: method_complexities.first[:line],
      message: "Methods with high complexity detected: #{complex_methods}",
      suggestion: 'Refactor complex methods into smaller, focused methods'
    }
  end
end

# Check Ruby naming conventions
def check_ruby_naming_conventions(file, content)
  # Check for class/module names that don't use CamelCase
  content.scan(/class\s+(\w+)/) do |match|
    class_name = match[0]
    unless class_name =~ /^[A-Z][a-zA-Z0-9]*$/
      ISSUES[:warnings] << {
        file: file,
        line: nil,
        message: "Class name '#{class_name}' doesn't follow CamelCase convention",
        suggestion: 'Use CamelCase for class and module names'
      }
    end
  end
  
  # Check for method/variable names that don't use snake_case
  content.scan(/def\s+(\w+)/) do |match|
    method_name = match[0]
    unless method_name =~ /^[a-z][a-z0-9_]*$/
      ISSUES[:warnings] << {
        file: file,
        line: nil,
        message: "Method name '#{method_name}' doesn't follow snake_case convention",
        suggestion: 'Use snake_case for method and variable names'
      }
    end
  end
  
  # Check for constant names that don't use SCREAMING_SNAKE_CASE
  content.scan(/([A-Z][A-Z0-9_]*)\s*=/) do |match|
    constant_name = match[0]
    unless constant_name =~ /^[A-Z][A-Z0-9_]*$/
      ISSUES[:warnings] << {
        file: file,
        line: nil,
        message: "Constant name '#{constant_name}' doesn't follow SCREAMING_SNAKE_CASE convention",
        suggestion: 'Use SCREAMING_SNAKE_CASE for constants'
      }
    end
  end
end

# JavaScript specific analysis
def analyze_js_file(file, content)
  # Check for console.log statements
  content.to_enum(:scan, /console\.(log|debug|info|error|warn)\(/).map do
    scan_index = Regexp.last_match.offset(0)[0]
    ISSUES[:warnings] << {
      file: file,
      line: content[0...scan_index].split("\n").length,
      message: "Found console.#{$1}() statement",
      suggestion: 'Remove debug statements before committing or use a logger library'
    }
  end
  
  # Check for unnecessary state management
  if content.include?('useState') && content.include?('useEffect')
    state_count = content.scan(/const\s+\[\w+,\s*set(\w+)\]\s*=\s*useState/).length
    effect_count = content.scan(/useEffect\(\s*\(\)\s*=>\s*{/).length
    
    if state_count > 5
      ISSUES[:suggestions] << {
        file: file,
        line: nil,
        message: "Component has #{state_count} state variables",
        suggestion: 'Consider breaking this component into smaller ones or using useReducer'
      }
    end
    
    if effect_count > 3
      ISSUES[:suggestions] << {
        file: file,
        line: nil,
        message: "Component has #{effect_count} useEffect hooks",
        suggestion: 'Multiple effects may indicate the component has too many responsibilities'
      }
    end
  end
  
  # Check for direct DOM manipulation
  if content.include?('document.') || content.include?('window.')
    ISSUES[:warnings] << {
      file: file,
      line: nil,
      message: 'Direct DOM manipulation detected',
      suggestion: 'Use framework-specific methods for DOM manipulation instead of direct access'
    }
  end
  
  # Check for accessibility issues
  check_js_accessibility(file, content)
  
  # Check for ES6+ features usage
  check_es6_usage(file, content)
end

# Accessibility checks for JavaScript
def check_js_accessibility(file, content)
  # Check for missing aria attributes on interactive elements
  if content.include?('onClick') || content.include?('addEventListener') || content.include?('role=')
    unless content.include?('aria-')
      ISSUES[:warnings] << {
        file: file,
        line: nil,
        message: 'Potential accessibility issue: Interactive elements may be missing ARIA attributes',
        suggestion: 'Add appropriate ARIA attributes like aria-label, aria-expanded, etc. to improve screen reader compatibility'
      }
    end
  end
  
  # Check for keyboard event handling if mouse events are used
  if (content.include?('onClick') || content.include?('onMouseDown')) && 
     !content.include?('onKeyDown') && !content.include?('onKeyPress')
    ISSUES[:warnings] << {
      file: file,
      line: nil,
      message: 'Potential accessibility issue: Mouse events without keyboard equivalents',
      suggestion: 'Add onKeyDown or onKeyPress handlers to ensure keyboard accessibility'
    }
  end
  
  # Check for proper focus management
  if content.include?('focus(') || content.include?('blur(')
    unless content.include?('tabIndex') || content.include?('tabindex')
      ISSUES[:warnings] << {
        file: file,
        line: nil,
        message: 'Potential accessibility issue: Custom focus management without proper tabIndex',
        suggestion: 'Ensure elements that receive focus have appropriate tabIndex values'
      }
    end
  end
end

# Check for modern ES6+ usage
def check_es6_usage(file, content)
  # Check for var instead of let/const
  if content.include?('var ')
    ISSUES[:suggestions] << {
      file: file,
      line: nil,
      message: 'Using var instead of let/const',
      suggestion: 'Prefer let and const over var for better scoping and immutability'
    }
  end
  
  # Check for function expressions instead of arrow functions
  if content.match(/function\s*\(/) && !content.include?('=>')
    ISSUES[:suggestions] << {
      file: file,
      line: nil,
      message: 'Using function expressions without arrow functions',
      suggestion: 'Consider using arrow functions for more concise syntax and lexical this binding'
    }
  end
  
  # Check for promise chains without async/await
  if content.include?('.then(') && !content.include?('async') && !content.include?('await')
    ISSUES[:suggestions] << {
      file: file,
      line: nil,
      message: 'Using promise chains without async/await',
      suggestion: 'Consider using async/await for more readable asynchronous code'
    }
  end
end

# Vue.js specific analysis
def analyze_vue_file(file, content)
  # Skip if not a Vue file
  return unless file.end_with?('.vue')
  
  # Check for proper component structure
  if !content.include?('<script>') || !content.include?('<template>')
    ISSUES[:warnings] << {
      file: file,
      line: nil,
      message: 'Vue component is missing script or template section',
      suggestion: 'Ensure component has both <template> and <script> sections'
    }
  end
  
  # Check for v-for without key
  content.to_enum(:scan, /<[^>]+v-for="[^"]+"/).map do
    scan_index = Regexp.last_match.offset(0)[0]
    element = Regexp.last_match[0]
    
    if !element.include?(':key=')
      ISSUES[:critical] << {
        file: file,
        line: content[0...scan_index].split("\n").length,
        message: 'v-for directive used without a :key attribute',
        suggestion: 'Always use a unique key with v-for to maintain component state and improve rendering performance'
      }
    end
  end
  
  # Check for props validation
  if content.include?('props:') && !content.include?('type:') && !content.include?('required:')
    ISSUES[:warnings] << {
      file: file,
      line: nil,
      message: 'Props may be missing type validation',
      suggestion: 'Define prop types and required status for better component documentation and error prevention'
    }
  end
  
  # Check for scoped styles
  if content.include?('<style>') && !content.include?('<style scoped>')
    ISSUES[:suggestions] << {
      file: file,
      line: nil,
      message: 'Component uses global styles instead of scoped styles',
      suggestion: 'Consider using scoped styles with <style scoped> to prevent CSS leaking to other components'
    }
  end
  
  # Check if component is too large
  template_length = 0
  in_template = false
  
  content.split("\n").each do |line|
    if line.include?('<template>')
      in_template = true
      next
    elsif line.include?('</template>')
      in_template = false
      next
    end
    
    template_length += 1 if in_template
  end
  
  if template_length > 100
    ISSUES[:warnings] << {
      file: file,
      line: nil,
      message: "Component template is very large (#{template_length} lines)",
      suggestion: 'Break large components into smaller, focused components'
    }
  end
  
  # Check for computed properties usage for derived data
  if content.include?('data()') && content.include?('return {')
    unless content.include?('computed:')
      ISSUES[:suggestions] << {
        file: file,
        line: nil,
        message: 'Component uses data() but may not be using computed properties for derived data',
        suggestion: 'Use computed properties for data that depends on other data'
      }
    end
  end
  
  # Check for accessibility issues
  check_vue_accessibility(file, content)
  
  # Check for proper event handling
  check_vue_events(file, content)
end

# Check Vue component accessibility
def check_vue_accessibility(file, content)
  # Check for missing aria attributes on interactive elements
  content.scan(/<(button|a|input|select)/).each do |match|
    element = match[0]
    if !content.include?("aria-") && !content.include?("role=")
      ISSUES[:warnings] << {
        file: file,
        line: nil,
        message: "Potential accessibility issue: #{element} element may be missing ARIA attributes",
        suggestion: "Add appropriate ARIA attributes to improve screen reader compatibility"
      }
      break  # Only add this warning once per file
    end
  end
  
  # Check for proper form labeling
  if content.include?('<input') && !content.include?('<label') && !content.include?('aria-label')
    ISSUES[:warnings] << {
      file: file,
      line: nil,
      message: 'Potential accessibility issue: Input elements without associated labels',
      suggestion: 'Add <label> elements or aria-label attributes for input fields'
    }
  end
  
  # Check for semantic HTML
  if content.include?('<div') && content.include?('click') && !content.include?('button') && !content.include?('role="button"')
    ISSUES[:warnings] << {
      file: file,
      line: nil,
      message: 'Potential accessibility issue: Clickable div without role="button"',
      suggestion: 'Use semantic HTML elements like <button> or add role="button" with appropriate keyboard handling'
    }
  end
end

# Check Vue event handling
def check_vue_events(file, content)
  # Check for appropriate event naming
  if content.match(/\$emit\(['"](?!update:|input|change|focus|blur|click|submit)[^'"]+['"]/)
    ISSUES[:suggestions] << {
      file: file,
      line: nil,
      message: 'Non-standard event names in $emit calls',
      suggestion: 'Consider using standard event names or prefixing custom events with "update:" for v-model support'
    }
  end
  
  # Check for event modifiers vs manual event handling
  if content.include?('preventDefault()') || content.include?('stopPropagation()')
    unless content.include?('.prevent') || content.include?('.stop')
      ISSUES[:suggestions] << {
        file: file,
        line: nil,
        message: 'Manual event handling instead of using Vue event modifiers',
        suggestion: 'Consider using Vue event modifiers like .prevent, .stop, .once for cleaner code'
      }
    end
  end
end

# GraphQL analysis
def analyze_graphql_file(file, content)
  # Check for missing descriptions
  if !content.include?('"""') && (content.include?('type ') || content.include?('input '))
    ISSUES[:suggestions] << {
      file: file,
      line: nil,
      message: 'GraphQL schema is missing descriptions',
      suggestion: 'Add descriptions using """ multi-line comments """ for types and fields'
    }
  end
  
  # Check for nullable ID fields
  if content.include?('id: ID') && !content.include?('id: ID!')
    ISSUES[:warnings] << {
      file: file,
      line: nil,
      message: 'GraphQL schema has nullable ID fields',
      suggestion: 'Consider making ID fields non-nullable with ID! type'
    }
  end
  
  # Check for pagination implementations
  if (content.include?('type Query') || content.include?('extend type Query')) && 
      content.include?(']: ') && !content.include?('Connection')
    ISSUES[:suggestions] << {
      file: file,
      line: nil,
      message: 'GraphQL query returning an array without pagination',
      suggestion: 'Consider implementing Relay-style connections or limit/offset pagination for lists'
    }
  end
  
  # Check for missing input validation
  if content.include?('input ') && !content.include?('ValidationError')
    ISSUES[:warnings] << {
      file: file,
      line: nil,
      message: 'GraphQL input type may be missing validation',
      suggestion: 'Consider adding validation for input types to improve error handling'
    }
  end
end

# Try to run external tools if they're available
def try_external_tools(changed_files)
  begin
    # Try running Rubocop if available
    ruby_files = changed_files.select { |f| CONFIG[:ruby_extensions].include?(File.extname(f)) }
    
    if command_exists?('rubocop') && !ruby_files.empty?
      puts 'Running Rubocop...'.blue
      begin
        rubocop_files = ruby_files.join(' ')
        rubocop_output = `rubocop --format json #{rubocop_files}`
        rubocop_result = JSON.parse(rubocop_output)
        
        if rubocop_result['files'] && rubocop_result['summary'] && rubocop_result['summary']['offense_count'] > 0
          rubocop_result['files'].each do |file|
            if file['offenses'] && !file['offenses'].empty?
              file['offenses'].each do |offense|
                ISSUES[:warnings] << {
                  file: file['path'],
                  line: offense['location']['line'],
                  message: "Rubocop: #{offense['message']} (#{offense['cop_name']})",
                  suggestion: offense['correctable'] ? 'Can be auto-corrected with `rubocop -a`' : ''
                }
              end
            end
          end
        end
      rescue => e
        # Rubocop might return non-zero exit code when it finds issues
        begin
          if $?.exitstatus != 0 && !$?.exitstatus.nil?
            rubocop_result = JSON.parse(rubocop_output)
            if rubocop_result['files']
              rubocop_result['files'].each do |file|
                if file['offenses'] && !file['offenses'].empty?
                  file['offenses'].each do |offense|
                    ISSUES[:warnings] << {
                      file: file['path'],
                      line: offense['location']['line'],
                      message: "Rubocop: #{offense['message']} (#{offense['cop_name']})",
                      suggestion: offense['correctable'] ? 'Can be auto-corrected with `rubocop -a`' : ''
                    }
                  end
                end
              end
            end
          end
        rescue
          # If we can't parse the output, just ignore
        end
      end
    end
    
    # Try running Brakeman for Rails security if available
    if command_exists?('brakeman') && File.exist?("config/routes.rb")
      puts 'Running Brakeman security scanner...'.blue
      begin
        brakeman_output = `brakeman -f json`
        brakeman_result = JSON.parse(brakeman_output)
        
        if brakeman_result['warnings'] && !brakeman_result['warnings'].empty?
          brakeman_result['warnings'].each do |warning|
            # Only include warnings for files we're reviewing
            if changed_files.any? { |f| f.end_with?(warning['file']) }
              ISSUES[:critical] << {
                file: warning['file'],
                line: warning['line'],
                message: "Security: #{warning['message']} (#{warning['warning_type']})",
                suggestion: warning['confidence'] == 'High' ? 'High confidence - fix immediately!' : 'Review and fix this security issue'
              }
            end
          end
        end
      rescue => e
        # If brakeman fails, just continue
      end
    end
    
    # Try running ESLint if available
    js_files = changed_files.select { |f| CONFIG[:js_extensions].include?(File.extname(f)) }
    
    if command_exists?('eslint') && !js_files.empty?
      puts 'Running ESLint...'.blue
      begin
        eslint_files = js_files.join(' ')
        eslint_output = `eslint --format json #{eslint_files}`
        eslint_result = JSON.parse(eslint_output)
        
        eslint_result.each do |file|
          if file['messages'] && !file['messages'].empty?
            file['messages'].each do |msg|
              severity = msg['severity'] == 2 ? :critical : :warnings
              ISSUES[severity] << {
                file: file['filePath'],
                line: msg['line'],
                message: "ESLint: #{msg['message']} (#{msg['ruleId']})",
                suggestion: msg['fix'] ? 'Can be auto-fixed with `eslint --fix`' : ''
              }
            end
          end
        end
      rescue => e
        # ESLint might return non-zero exit code when it finds issues
        begin
          if $?.exitstatus != 0 && !$?.exitstatus.nil?
            eslint_result = JSON.parse(eslint_output)
            eslint_result.each do |file|
              if file['messages'] && !file['messages'].empty?
                file['messages'].each do |msg|
                  severity = msg['severity'] == 2 ? :critical : :warnings
                  ISSUES[severity] << {
                    file: file['filePath'],
                    line: msg['line'],
                    message: "ESLint: #{msg['message']} (#{msg['ruleId']})",
                    suggestion: msg['fix'] ? 'Can be auto-fixed with `eslint --fix`' : ''
                  }
                end
              end
            end
          end
        rescue
          # If we can't parse the output, just ignore
        end
      end
    end
  rescue => e
    puts "Error running external tools: #{e.message}".yellow
  end
end

# Generate and display the report
def generate_report
  puts "\n" + ' CRITICAL ISSUES '.on_red.white + ' ' + ISSUES[:critical].length.to_s
  ISSUES[:critical].each do |issue|
    line_info = issue[:line] ? ":#{issue[:line]}" : ''
    puts "#{issue[:file]}#{line_info}".red
    puts "  ✖ #{issue[:message]}".red
    puts "    ↪ #{issue[:suggestion]}".yellow
  end
  
  puts "\n" + ' WARNINGS '.on_yellow.black + ' ' + ISSUES[:warnings].length.to_s
  ISSUES[:warnings].each do |issue|
    line_info = issue[:line] ? ":#{issue[:line]}" : ''
    puts "#{issue[:file]}#{line_info}".yellow
    puts "  ⚠ #{issue[:message]}".yellow
    puts "    ↪ #{issue[:suggestion]}".blue
  end
  
  puts "\n" + ' SUGGESTIONS '.on_blue.white + ' ' + ISSUES[:suggestions].length.to_s
  ISSUES[:suggestions].each do |issue|
    line_info = issue[:line] ? ":#{issue[:line]}" : ''
    puts "#{issue[:file]}#{line_info}".blue
    puts "  ℹ #{issue[:message]}".blue
    puts "    ↪ #{issue[:suggestion]}".green
  end
  
  # Generate a summary
  total = ISSUES[:critical].length + ISSUES[:warnings].length + ISSUES[:suggestions].length
  puts "\n" + ' SUMMARY '.on_white.black
  puts "Found #{total} issues (#{ISSUES[:critical].length} critical, #{ISSUES[:warnings].length} warnings, #{ISSUES[:suggestions].length} suggestions)".white
  
  # Add some common tips
  puts "\n" + ' TIPS '.on_white.black
  puts <<-TIPS.white
• Run this tool regularly before submitting code for review
• Address critical issues first
• Set up pre-commit hooks to catch issues early
• Consider adding the configuration to your CI pipeline
  TIPS
  
  # Add nCino-specific guidance
  puts "\n" + ' nCINO BEST PRACTICES '.on_white.black
  puts <<-NCINO.white
• Follow "fat models, skinny controllers" pattern
• Keep methods small and focused (single responsibility)
• Use service objects to encapsulate complex business logic
• Ensure Vue.js components follow proper conventions:
  - Keep components small and focused
  - Use props for component communication
  - Add proper validation for props
  - Use scoped styles to prevent CSS leaking
• Use ActiveRecord best practices:
  - Add indexes for frequently queried columns
  - Avoid N+1 queries using includes/eager loading
  - Add proper constraints and validations
• Follow accessibility guidelines:
  - Use semantic HTML elements
  - Add proper ARIA attributes
  - Ensure keyboard navigation works
  NCINO
  
  # Generate JSON report for CI integration
  json_report = {
    summary: {
      total: total,
      critical: ISSUES[:critical].length,
      warnings: ISSUES[:warnings].length,
      suggestions: ISSUES[:suggestions].length
    },
    issues: ISSUES
  }
  
  File.write('code_review_report.json', JSON.pretty_generate(json_report))
  puts "\nJSON report saved to code_review_report.json".blue
end

# Utility method to prepare for Git pre-commit hook
def generate_pre_commit_hook
  hook_path = '.git/hooks/pre-commit'
  hook_content = <<~HOOK
    #!/bin/sh
    # Auto Code Review pre-commit hook
    ruby #{File.expand_path(__FILE__)} .
    if [ $? -ne 0 ]; then
      echo "\\033[0;31mCode review found critical issues. Commit aborted.\\033[0m"
      echo "\\033[0;31mFix the issues or use --no-verify to bypass (not recommended).\\033[0m"
      exit 1
    fi
  HOOK
  
  # Check if hooks directory exists
  unless Dir.exist?('.git/hooks')
    puts "No .git/hooks directory found. Are you in a git repository?".red
    return false
  end
  
  # Write the hook file
  File.write(hook_path, hook_content)
  FileUtils.chmod(0755, hook_path)
  puts "Pre-commit hook installed successfully at #{hook_path}".green
  return true
end

# Main function
def main
  # Parse command-line options
  options = parse_options
  
  # Handle pre-commit hook installation
  if options[:install_hook]
    exit(generate_pre_commit_hook ? 0 : 1)
  end
  
  start_time = Time.now
  puts "🔍 Starting AutoCodeReview...".blue
  
  # Check if we're in a git repository
  unless in_git_repo?
    puts "Not in a git repository. Please run this script from within a git repository.".red
    exit 1
  end
  
  # Prompt for GitHub repository URL if not provided
  if options[:repo_url].nil?
    options[:repo_url] = prompt("Enter GitHub repository URL", CONFIG[:default_repo_url])
  end
  
  unless valid_github_url?(options[:repo_url])
    puts "Warning: '#{options[:repo_url]}' doesn't appear to be a valid GitHub URL. Using it anyway.".yellow
  end
  
  puts "Repository: #{options[:repo_url]}".blue
  
  # Prompt for base branch if not provided
  if options[:base_branch].nil?
    options[:base_branch] = prompt("Enter base branch to compare against", CONFIG[:default_base_branch])
  end
  
  # Prompt for compare branch if not provided
  if options[:compare_branch].nil?
    current = current_branch
    options[:compare_branch] = prompt("Enter branch with changes to review", current || "HEAD")
  end
  
  puts "Comparing branches: #{options[:base_branch]}..#{options[:compare_branch]}".blue
  
  # Get files changed between branches
  changed_files = get_changed_files(options[:base_branch], options[:compare_branch])
  
  if changed_files.empty?
    puts "No files changed between #{options[:base_branch]} and #{options[:compare_branch]}".yellow
    exit 0
  end
  
  puts "Found #{changed_files.size} changed files to analyze".blue
  
  # Filter changed files to only include relevant file types
  valid_extensions = [
    *CONFIG[:ruby_extensions],
    *CONFIG[:js_extensions],
    *CONFIG[:graphql_extensions]
  ]
  
  files_to_analyze = changed_files.select do |file|
    ext = File.extname(file)
    File.exist?(file) && valid_extensions.include?(ext) && 
      !CONFIG[:ignore_dirs].any? { |dir| file.start_with?(dir) } &&
      !CONFIG[:ignore_files].include?(File.basename(file))
  end
  
  puts "Analyzing #{files_to_analyze.size} relevant files".blue
  
  # Review the files
  review_files(files_to_analyze)
  
  # Try to run external tools on changed files
  try_external_tools(files_to_analyze)
  
  # Generate report
  generate_report
  
  # Generate PR draft
  generate_pr_draft(options[:base_branch], options[:compare_branch], changed_files)
  
  end_time = Time.now
  duration = (end_time - start_time).to_f
  puts "✅ Review completed in #{duration.round(2)} seconds".blue
end

# Run the main function if this script is executed directly
if __FILE__ == $0
  main
  # Exit with error code 1 if there are critical issues (useful for CI integration)
  exit(ISSUES[:critical].empty? ? 0 : 1)
end
