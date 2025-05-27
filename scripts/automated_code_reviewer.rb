#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'json'
require 'yaml'
require 'fileutils'
require 'open3'

class AutomatedCodeReviewer
  attr_reader :options, :review_results

  def initialize
    @options = {
      path: '.',
      pr_number: nil,
      output_format: 'markdown',
      config_file: '.code_review.yml',
      verbose: false,
      github_format: false
    }
    @review_results = {
      positives: [],
      security_issues: [],
      performance_issues: [],
      clean_code_issues: [],
      accessibility_issues: [],
      maintainability_issues: [],
      best_practice_issues: []
    }
    parse_options
    load_config
  end

  def run
    puts "🔍 Starting automated code review..." if options[:verbose]
    
    changed_files = get_changed_files
    return puts "No files to review" if changed_files.empty?

    analyze_files(changed_files)
    generate_review_comment
  end

  private

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: code_reviewer.rb [options]"

      opts.on("-p", "--path PATH", "Path to the project") do |path|
        options[:path] = path
      end

      opts.on("-n", "--pr-number NUMBER", "Pull request number") do |pr|
        options[:pr_number] = pr
      end

      opts.on("-f", "--format FORMAT", "Output format (markdown, json, github)") do |format|
        options[:output_format] = format
        options[:github_format] = true if format == 'github'
      end

      opts.on("-c", "--config FILE", "Configuration file path") do |config|
        options[:config_file] = config
      end

      opts.on("-v", "--verbose", "Verbose output") do
        options[:verbose] = true
      end

      opts.on("-h", "--help", "Show help") do
        puts opts
        exit
      end
    end.parse!
  end

  def load_config
    config_path = File.join(options[:path], options[:config_file])
    return unless File.exist?(config_path)

    config = YAML.load_file(config_path)
    @config = config || {}
  end

  def get_changed_files
    # Try to get changed files from git
    if system('git rev-parse --git-dir > /dev/null 2>&1')
      stdout, stderr, status = Open3.capture3('git diff --name-only HEAD~1')
      if status.success?
        return stdout.split("\n").select { |f| reviewable_file?(f) }
      end
    end

    # Fallback: scan all Ruby/JS/Vue files in common directories
    patterns = %w[
      app/**/*.rb
      lib/**/*.rb
      app/**/*.js
      app/**/*.vue
      app/**/*.erb
      spec/**/*.rb
      test/**/*.rb
    ]

    files = []
    patterns.each do |pattern|
      files.concat(Dir.glob(File.join(options[:path], pattern)))
    end

    files.select { |f| File.exist?(f) && reviewable_file?(f) }
  end

  def reviewable_file?(filename)
    extensions = %w[.rb .js .vue .erb .haml .slim]
    extensions.any? { |ext| filename.end_with?(ext) }
  end

  def analyze_files(files)
    puts "📁 Analyzing #{files.length} files..." if options[:verbose]

    files.each do |file|
      puts "  Reviewing #{File.basename(file)}..." if options[:verbose]
      analyze_file(file)
    end

    find_positive_patterns(files) if review_results[:security_issues].empty? && review_results[:performance_issues].empty?
  end

  def analyze_file(file_path)
    content = File.read(file_path)
    filename = File.basename(file_path)
    extension = File.extname(file_path)

    case extension
    when '.rb'
      analyze_ruby_file(content, filename)
    when '.js', '.vue'
      analyze_javascript_file(content, filename)
    when '.erb', '.haml', '.slim'
      analyze_template_file(content, filename)
    end
  end

  def analyze_ruby_file(content, filename)
    check_ruby_security(content, filename)
    check_ruby_performance(content, filename)
    check_ruby_clean_code(content, filename)
    check_ruby_best_practices(content, filename)
    check_ruby_maintainability(content, filename)
  end

  def check_ruby_security(content, filename)
    # CSRF protection
    if filename.include?('controller') && content.match(/skip_before_action.*verify_authenticity_token/)
      review_results[:security_issues] << {
        file: filename,
        type: 'CSRF Vulnerability',
        line: find_line_number(content, /skip_before_action.*verify_authenticity_token/),
        description: 'Skipping CSRF protection can expose users to cross-site request forgery attacks.',
        suggestion: 'Remove skip_before_action or use protect_from_forgery with: :exception'
      }
    end

    # SQL injection risks
    if content.match(/\.where\(\s*["'].*\#\{/) || content.match(/\.find_by_sql\(\s*["'].*\#\{/)
      review_results[:security_issues] << {
        file: filename,
        type: 'SQL Injection Risk',
        line: find_line_number(content, /\.where\(\s*["'].*\#\{/),
        description: 'String interpolation in SQL queries can lead to SQL injection.',
        suggestion: 'Use parameterized queries or ActiveRecord methods with placeholders'
      }
    end

    # Mass assignment
    if filename.include?('controller') && content.match(/params\[:/) && !content.match(/params\.require\(/)
      review_results[:security_issues] << {
        file: filename,
        type: 'Mass Assignment Risk',
        line: find_line_number(content, /params\[:/),
        description: 'Direct parameter access without strong parameters can lead to mass assignment.',
        suggestion: 'Use strong parameters with params.require().permit()'
      }
    end
  end

  def check_ruby_performance(content, filename)
    # N+1 queries
    if content.match(/\.all\b/) && !content.match(/\.includes\(/) && filename.include?('controller')
      review_results[:performance_issues] << {
        file: filename,
        type: 'Potential N+1 Query',
        line: find_line_number(content, /\.all\b/),
        description: 'Using .all without eager loading can cause N+1 query problems.',
        suggestion: 'Consider using .includes() to eager load associations'
      }
    end

    # Inefficient loops
    if content.match(/\.each\b/) && !content.match(/\.find_each\b/) && content.match(/\.(save|create|update)/)
      review_results[:performance_issues] << {
        file: filename,
        type: 'Inefficient Bulk Operations',
        line: find_line_number(content, /\.each\b/),
        description: 'Using .each with database operations can be slow for large datasets.',
        suggestion: 'Consider using .find_each or bulk operations like .insert_all'
      }
    end
  end

  def check_ruby_clean_code(content, filename)
    lines = content.split("\n")
    
    # Method length
    method_starts = []
    method_ends = []
    
    lines.each_with_index do |line, index|
      method_starts << index if line.match(/^\s*def\s+/)
      method_ends << index if line.match(/^\s*end\s*$/)
    end

    method_starts.each do |start|
      corresponding_end = method_ends.find { |e| e > start }
      next unless corresponding_end
      
      method_length = corresponding_end - start
      if method_length > 20
        method_name = lines[start].match(/def\s+(\w+)/)[1] rescue 'unknown'
        review_results[:clean_code_issues] << {
          file: filename,
          type: 'Long Method',
          line: start + 1,
          description: "Method '#{method_name}' is #{method_length} lines long.",
          suggestion: 'Consider breaking this method into smaller, focused methods'
        }
      end
    end

    # Complex conditionals
    lines.each_with_index do |line, index|
      if line.count('&&') + line.count('||') > 2
        review_results[:clean_code_issues] << {
          file: filename,
          type: 'Complex Conditional',
          line: index + 1,
          description: 'Complex conditional logic can be hard to understand.',
          suggestion: 'Consider extracting conditions into well-named methods'
        }
      end
    end
  end

  def check_ruby_best_practices(content, filename)
    # Missing error handling
    if filename.include?('controller') && !content.match(/rescue|begin|errors/)
      review_results[:best_practice_issues] << {
        file: filename,
        type: 'Missing Error Handling',
        line: 1,
        description: 'Controller lacks visible error handling.',
        suggestion: 'Add proper error handling with rescue blocks or error callbacks'
      }
    end

    # Hardcoded strings that should be i18n
    hardcoded_strings = content.scan(/"([A-Z][^"]{10,})"/).flatten
    if hardcoded_strings.length > 3 && !filename.include?('spec') && !filename.include?('test')
      review_results[:best_practice_issues] << {
        file: filename,
        type: 'Hardcoded Strings',
        line: 1,
        description: "Found #{hardcoded_strings.length} potentially hardcoded user-facing strings.",
        suggestion: 'Consider using I18n.t() for user-facing strings'
      }
    end
  end

  def check_ruby_maintainability(content, filename)
    # Lack of comments in complex files
    lines = content.split("\n")
    code_lines = lines.reject { |line| line.strip.empty? || line.strip.start_with?('#') }
    comment_lines = lines.select { |line| line.strip.start_with?('#') }
    
    if code_lines.length > 50 && comment_lines.length < 3
      review_results[:maintainability_issues] << {
        file: filename,
        type: 'Insufficient Documentation',
        line: 1,
        description: 'Large file with minimal comments or documentation.',
        suggestion: 'Add comments explaining complex business logic and method purposes'
      }
    end
  end

  def analyze_javascript_file(content, filename)
    check_js_accessibility(content, filename)
    check_js_best_practices(content, filename)
  end

  def check_js_accessibility(content, filename)
    # Missing ARIA attributes
    if content.match(/<button/) && !content.match(/aria-/)
      review_results[:accessibility_issues] << {
        file: filename,
        type: 'Missing ARIA Attributes',
        line: find_line_number(content, /<button/),
        description: 'Interactive elements should have proper ARIA attributes.',
        suggestion: 'Add aria-label, aria-expanded, or other relevant ARIA attributes'
      }
    end

    # Missing alt text
    if content.match(/<img/) && !content.match(/alt=/)
      review_results[:accessibility_issues] << {
        file: filename,
        type: 'Missing Alt Text',
        line: find_line_number(content, /<img/),
        description: 'Images should have descriptive alt text.',
        suggestion: 'Add meaningful alt attributes to all images'
      }
    end
  end

  def check_js_best_practices(content, filename)
    # Console.log in production code
    if content.match(/console\.log/) && !filename.include?('test') && !filename.include?('spec')
      review_results[:best_practice_issues] << {
        file: filename,
        type: 'Debug Code',
        line: find_line_number(content, /console\.log/),
        description: 'Console.log statements should not be in production code.',
        suggestion: 'Remove console.log or use a proper logging library'
      }
    end
  end

  def analyze_template_file(content, filename)
    check_template_accessibility(content, filename)
  end

  def check_template_accessibility(content, filename)
    # Form inputs without labels
    if content.match(/<input/) && !content.match(/label.*for=|aria-label/)
      review_results[:accessibility_issues] << {
        file: filename,
        type: 'Form Accessibility',
        line: find_line_number(content, /<input/),
        description: 'Form inputs should have associated labels.',
        suggestion: 'Add proper labels or aria-label attributes to form inputs'
      }
    end
  end

  def find_positive_patterns(files)
    # Look for good patterns to highlight
    files.each do |file|
      content = File.read(file)
      filename = File.basename(file)

      # Service objects
      if filename.include?('service') && content.match(/class.*Service/)
        review_results[:positives] << "Great use of service objects to encapsulate business logic in #{filename}!"
      end

      # Strong parameters
      if content.match(/params\.require\(.*\)\.permit\(/)
        review_results[:positives] << "Nice job using strong parameters for security in #{filename}!"
      end

      # Eager loading
      if content.match(/\.includes\(/)
        review_results[:positives] << "Good performance optimization with eager loading in #{filename}!"
      end

      # Test coverage
      if filename.include?('_spec.rb') || filename.include?('_test.rb')
        review_results[:positives] << "Excellent test coverage - keep it up!"
        break # Only mention this once
      end
    end

    # Default positive if no specific patterns found
    if review_results[:positives].empty?
      review_results[:positives] << "The code is working as expected, which is great!"
    end
  end

  def find_line_number(content, pattern)
    lines = content.split("\n")
    lines.each_with_index do |line, index|
      return index + 1 if line.match(pattern)
    end
    1
  end

  def generate_review_comment
    case options[:output_format]
    when 'json'
      puts JSON.pretty_generate(review_results)
    when 'github'
      puts generate_github_comment
    else
      puts generate_markdown_comment
    end
  end

  def generate_markdown_comment
    comment = []
    
    comment << "# Automated Code Review 🤖"
    comment << ""

    # Overall impression with positives
    comment << "## Overall Impression"
    if review_results[:positives].any?
      comment << "Hey there! Thanks for the PR. #{review_results[:positives].first}"
      comment << ""
    end

    total_issues = count_total_issues
    
    if total_issues == 0
      comment << "Everything looks solid! No major issues found. 🎉"
      comment << ""
    else
      comment << "Found #{total_issues} potential improvement(s). Let's make this code even better! 💪"
      comment << ""
    end

    # Security issues
    if review_results[:security_issues].any?
      comment << "## 🔒 Security Concerns"
      review_results[:security_issues].each_with_index do |issue, index|
        comment << format_issue(issue, index + 1)
      end
      comment << ""
    end

    # Performance issues
    if review_results[:performance_issues].any?
      comment << "## ⚡ Performance Optimizations"
      review_results[:performance_issues].each_with_index do |issue, index|
        comment << format_issue(issue, index + 1)
      end
      comment << ""
    end

    # Clean code issues
    if review_results[:clean_code_issues].any?
      comment << "## 🧹 Clean Code Suggestions"
      review_results[:clean_code_issues].each_with_index do |issue, index|
        comment << format_issue(issue, index + 1)
      end
      comment << ""
    end

    # Accessibility issues
    if review_results[:accessibility_issues].any?
      comment << "## ♿ Accessibility Improvements"
      review_results[:accessibility_issues].each_with_index do |issue, index|
        comment << format_issue(issue, index + 1)
      end
      comment << ""
    end

    # Best practices
    if review_results[:best_practice_issues].any?
      comment << "## 📋 Best Practice Suggestions"
      review_results[:best_practice_issues].each_with_index do |issue, index|
        comment << format_issue(issue, index + 1)
      end
      comment << ""
    end

    # Maintainability
    if review_results[:maintainability_issues].any?
      comment << "## 🔧 Maintainability Notes"
      review_results[:maintainability_issues].each_with_index do |issue, index|
        comment << format_issue(issue, index + 1)
      end
      comment << ""
    end

    # Closing
    if total_issues > 0
      comment << "## Summary"
      comment << "These suggestions will help make the code more secure, performant, and maintainable."
      comment << "Feel free to ask questions about any of these recommendations! 🚀"
    end

    comment.join("\n")
  end

  def generate_github_comment
    # Generate GitHub-compatible comment format
    comment = generate_markdown_comment
    
    # Add GitHub-specific formatting
    if options[:pr_number]
      comment.prepend("<!-- Automated review for PR ##{options[:pr_number]} -->\n")
    end
    
    comment
  end

  def format_issue(issue, number)
    formatted = []
    formatted << "### #{number}. #{issue[:type]} in `#{issue[:file]}`"
    formatted << "**Line #{issue[:line]}:** #{issue[:description]}"
    formatted << ""
    formatted << "**Suggestion:** #{issue[:suggestion]}"
    formatted << ""
    formatted.join("\n")
  end

  def count_total_issues
    [
      :security_issues,
      :performance_issues,
      :clean_code_issues,
      :accessibility_issues,
      :best_practice_issues,
      :maintainability_issues
    ].sum { |category| review_results[category].length }
  end
end

# Configuration file example
def create_sample_config
  config = {
    'rules' => {
      'max_method_length' => 20,
      'max_complexity' => 10,
      'require_tests' => true,
      'check_accessibility' => true
    },
    'ignore_files' => [
      'db/schema.rb',
      'config/routes.rb'
    ],
    'custom_patterns' => {
      'deprecated_methods' => ['find_by_sql', 'execute']
    }
  }

  File.write('.code_review.yml', config.to_yaml)
  puts "Created sample configuration file: .code_review.yml"
end

# CLI execution
if __FILE__ == $0
  if ARGV.include?('--setup')
    create_sample_config
    exit 0
  end

  begin
    AutomatedCodeReviewer.new.run
  rescue => e
    puts "Error: #{e.message}"
    puts e.backtrace.join("\n") if ENV['DEBUG']
    exit 1
  end
end