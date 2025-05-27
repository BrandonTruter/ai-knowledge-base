#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'json'
require 'colorize'
require 'fileutils'
require 'yaml'

class CodeReviewAutomation
  attr_reader :options

  def initialize
    @options = {
      path: '.',
      output: 'code_review_report.md',
      checks: ['all'],
      verbose: false
    }
    parse_options
  end

  def run
    puts "Starting code review for #{options[:path]}...".green

    report = []
    report << "# Code Review Report"
    report << "Generated on: #{Time.now}"
    report << "Target: #{File.expand_path(options[:path])}"
    report << ""

    if options[:checks].include?('all') || options[:checks].include?('functionality')
      report << functionality_check
    end

    if options[:checks].include?('all') || options[:checks].include?('performance')
      report << performance_check
    end

    # if options[:checks].include?('all') || options[:checks].include?('security')
    #   report << security_check
    # end

    # if options[:checks].include?('all') || options[:checks].include?('best_practices')
    #   report << best_practices_check
    # end

    report << "\n## Summary"
    report << "This automated review is intended as a starting point. Please perform a manual review to catch context-specific issues."

    File.write(options[:output], report.join("\n\n"))
    puts "Code review completed! Report saved to #{options[:output]}".green
  end

  private

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: code_review.rb [options]"

      opts.on("-p", "--path PATH", "Path to the Rails project") do |path|
        options[:path] = path
      end

      opts.on("-o", "--output FILE", "Output report file") do |output|
        options[:output] = output
      end

      opts.on("-c", "--checks x,y,z", Array, "Specific checks to run (functionality, performance, security, best_practices, all)") do |checks|
        options[:checks] = checks
      end

      opts.on("-v", "--verbose", "Run with verbose output") do
        options[:verbose] = true
      end

      opts.on("-h", "--help", "Show this help message") do
        puts opts
        exit
      end
    end.parse!
  end

  def functionality_check
    puts "Checking functionality...".blue if options[:verbose]

    sections = []
    sections << "## Functionality"

    # Check for test coverage
    test_coverage = check_test_coverage
    sections << "### Test Coverage"
    sections << test_coverage

    # Check for error handling
    error_handling = check_error_handling
    sections << "### Error Handling"
    sections << error_handling

    sections.join("\n\n")
  end

  def performance_check
    puts "Checking performance...".blue if options[:verbose]

    sections = []
    sections << "## Performance"

    # Check for N+1 queries
    n_plus_one = check_n_plus_one
    sections << "### N+1 Query Issues"
    sections << n_plus_one

    # Check for missing indexes
    missing_indexes = check_missing_indexes
    sections << "### Missing Database Indexes"
    sections << missing_indexes

    sections.join("\n\n")
  end

  # def security_check
  #   puts "Checking security...".blue if options[:verbose]
  #
  #   sections = []
  #   sections << "## Security"
  #
  #   # Check for mass assignment vulnerabilities
  #   mass_assignment = check_mass_assignment
  #   sections << "### Mass Assignment Vulnerabilities"
  #   sections << mass_assignment
  #
  #   # Check for SQL injection risks
  #   sql_injection = check_sql_injection
  #   sections << "### SQL Injection Risks"
  #   sections << sql_injection
  #
  #   # Check for missing CSRF protection
  #   csrf = check_csrf_protection
  #   sections << "### CSRF Protection"
  #   sections << csrf
  #
  #   sections.join("\n\n")
  # end

  # def best_practices_check
  #   puts "Checking best practices...".blue if options[:verbose]
  #
  #   sections = []
  #   sections << "## Best Practices"
  #
  #   # Check for Rails conventions
  #   conventions = check_rails_conventions
  #   sections << "### Rails Conventions"
  #   sections << conventions
  #
  #   # Check for code complexity
  #   complexity = check_code_complexity
  #   sections << "### Code Complexity"
  #   sections << complexity
  #
  #   # Check for i18n usage
  #   i18n = check_i18n_usage
  #   sections << "### I18n Usage"
  #   sections << i18n
  #
  #   sections.join("\n\n")
  # end

  # Functionality checks
  def check_test_coverage
    test_dir = File.join(options[:path], 'test')
    spec_dir = File.join(options[:path], 'spec')

    if !Dir.exist?(test_dir) && !Dir.exist?(spec_dir)
      return "⚠️ No test directory found. Consider adding tests for your application."
    end

    # Count test files as a basic metric
    test_count = Dir.glob(File.join(test_dir, '**', '*_test.rb')).count if Dir.exist?(test_dir)
    spec_count = Dir.glob(File.join(spec_dir, '**', '*_spec.rb')).count if Dir.exist?(spec_dir)

    total_tests = (test_count || 0) + (spec_count || 0)

    if total_tests < 10
      "🔴 Low test coverage detected: only #{total_tests} test files found. Consider adding more tests."
    else
      "✅ Found #{total_tests} test files. For a more detailed analysis, consider using SimpleCov gem."
    end
  end

  def check_error_handling
    controller_dir = File.join(options[:path], 'app', 'controllers')
    return "Could not find controllers directory" unless Dir.exist?(controller_dir)

    controllers = Dir.glob(File.join(controller_dir, '**', '*.rb'))
    issues = []

    controllers.each do |controller|
      content = File.read(controller)

      # Very basic check for rescue blocks or error handling
      unless content.include?('rescue') || content.include?('begin') || content.include?('errors')
        issues << "- #{File.basename(controller)}: No visible error handling found"
      end
    end

    if issues.empty?
      "✅ Basic error handling found in controllers."
    else
      "🔴 Potential error handling issues:\n#{issues.join("\n")}\n\nConsider adding proper error handling to these controllers."
    end
  end

  # Performance checks
  def check_n_plus_one
    controller_dir = File.join(options[:path], 'app', 'controllers')
    return "Could not find controllers directory" unless Dir.exist?(controller_dir)

    controllers = Dir.glob(File.join(controller_dir, '**', '*.rb'))
    issues = []

    controllers.each do |controller|
      content = File.read(controller)

      # Very basic check for .all without includes
      if content.match(/\.all\b/) && !content.match(/\.includes\(/)
        issues << "- #{File.basename(controller)}: Possible N+1 query (using .all without .includes)"
      end

      # Look for .find_each which is more efficient for large datasets
      if content.match(/\.each\b/) && !content.match(/\.find_each\b/)
        issues << "- #{File.basename(controller)}: Consider using .find_each for large collections"
      end
    end

    if issues.empty?
      "✅ No obvious N+1 query issues detected."
    else
      "🔶 Potential N+1 query issues:\n#{issues.join("\n")}\n\nConsider using eager loading with .includes() to prevent N+1 queries."
    end
  end

  def check_missing_indexes
    schema_file = File.join(options[:path], 'db', 'schema.rb')
    return "Could not find schema.rb" unless File.exist?(schema_file)

    schema = File.read(schema_file)
    model_dir = File.join(options[:path], 'app', 'models')
    issues = []

    # Very basic check for foreign keys without indexes
    Dir.glob(File.join(model_dir, '*.rb')).each do |model_file|
      model_content = File.read(model_file)

      # Extract belongs_to associations
      belongs_to_matches = model_content.scan(/belongs_to\s+:(\w+)/)

      belongs_to_matches.each do |match|
        foreign_key = "#{match[0]}_id"

        # Check if there's an index on this foreign key
        unless schema.match(/add_index.+:#{foreign_key}/) ||
               schema.match(/t\.index.+:#{foreign_key}/)
          issues << "- #{File.basename(model_file)}: Missing index on foreign key '#{foreign_key}'"
        end
      end
    end

    if issues.empty?
      "✅ Foreign keys appear to be properly indexed."
    else
      "🔶 Potential missing indexes on foreign keys:\n#{issues.join("\n")}\n\nConsider adding indexes to these foreign keys to improve query performance."
    end
  end

  # Security checks
  def check_mass_assignment
    model_dir = File.join(options[:path], 'app', 'models')
    return "Could not find models directory" unless Dir.exist?(model_dir)

    controller_dir = File.join(options[:path], 'app', 'controllers')
    issues = []

    # Check models for attr_accessible or strong params
    Dir.glob(File.join(model_dir, '**', '*.rb')).each do |model|
      content = File.read(model)
      model_name = File.basename(model, '.rb')

      # Rails 3.x style
      if !content.match(/attr_accessible/) && !content.match(/strong_parameters/)
        # Check if there's a corresponding controller using strong parameters
        controller_file = File.join(controller_dir, "#{model_name.pluralize}_controller.rb")

        if File.exist?(controller_file)
          controller_content = File.read(controller_file)
          unless controller_content.match(/params\.require\(/) || controller_content.match(/params\.permit\(/)
            issues << "- #{model_name}: No mass assignment protection found"
          end
        else
          issues << "- #{model_name}: No controller found to check for strong parameters"
        end
      end
    end

    if issues.empty?
      "✅ Models appear to be protected against mass assignment."
    else
      "🔴 Potential mass assignment vulnerabilities:\n#{issues.join("\n")}\n\nConsider using strong parameters in your controllers."
    end
  end

  def check_sql_injection
    dirs_to_check = [
      File.join(options[:path], 'app', 'models'),
      File.join(options[:path], 'app', 'controllers')
    ]

    issues = []

    dirs_to_check.each do |dir|
      next unless Dir.exist?(dir)

      Dir.glob(File.join(dir, '**', '*.rb')).each do |file|
        content = File.read(file)

        # Check for raw SQL usage that might accept user input
        if content.match(/\.where\(\s*["'].*\#\{/) ||
           content.match(/\.find_by_sql\(\s*["'].*\#\{/) ||
           content.match(/Model\.find\(\s*["'].*\#\{/) ||
           content.match(/execute\(\s*["'].*\#\{/)
          issues << "- #{File.basename(file)}: Possible SQL injection risk with interpolated values in SQL"
        end
      end
    end

    if issues.empty?
      "✅ No obvious SQL injection risks detected."
    else
      "🔴 Potential SQL injection vulnerabilities:\n#{issues.join("\n")}\n\nUse parameterized queries or ActiveRecord methods instead of string interpolation in SQL."
    end
  end

  def check_csrf_protection
    app_controller = File.join(options[:path], 'app', 'controllers', 'application_controller.rb')
    return "Could not find application_controller.rb" unless File.exist?(app_controller)

    content = File.read(app_controller)

    if content.match(/protect_from_forgery/) && !content.match(/skip_before_action\s+:verify_authenticity_token/)
      "✅ CSRF protection is enabled."
    else
      "🔴 CSRF protection may be disabled or bypassed. Ensure 'protect_from_forgery with: :exception' is in ApplicationController."
    end
  end

  # Best practices checks
  def check_rails_conventions
    issues = []

    # Check model naming conventions
    model_dir = File.join(options[:path], 'app', 'models')
    if Dir.exist?(model_dir)
      Dir.glob(File.join(model_dir, '*.rb')).each do |model|
        basename = File.basename(model, '.rb')
        unless basename.singularize == basename
          issues << "- #{basename}: Model names should be singular"
        end
      end
    end

    # Check controller naming conventions
    controller_dir = File.join(options[:path], 'app', 'controllers')
    if Dir.exist?(controller_dir)
      Dir.glob(File.join(controller_dir, '*.rb')).each do |controller|
        basename = File.basename(controller, '_controller.rb')
        if basename.singularize == basename && basename != 'application'
          issues << "- #{basename}_controller.rb: Controller names should be plural (except ApplicationController)"
        end
      end
    end

    if issues.empty?
      "✅ File naming conventions appear to be followed."
    else
      "🔶 Convention issues:\n#{issues.join("\n")}\n\nConsider renaming these files to follow Rails conventions."
    end
  end

  def check_code_complexity
    dirs_to_check = [
      File.join(options[:path], 'app', 'models'),
      File.join(options[:path], 'app', 'controllers'),
      File.join(options[:path], 'app', 'helpers')
    ]

    issues = []

    dirs_to_check.each do |dir|
      next unless Dir.exist?(dir)

      Dir.glob(File.join(dir, '**', '*.rb')).each do |file|
        content = File.read(file)
        lines = content.lines

        # Check method length
        methods = content.scan(/def\s+(\w+)/)
        method_start_lines = []

        methods.each do |method_name|
          lines.each_with_index do |line, index|
            if line.match(/def\s+#{method_name[0]}/)
              method_start_lines << index
              break
            end
          end
        end

        # Very rough method length check
        method_start_lines.each_with_index do |start_line, index|
          end_line = index < method_start_lines.length - 1 ? method_start_lines[index + 1] : lines.length
          method_length = end_line - start_line

          if method_length > 20
            issues << "- #{File.basename(file)}: Method at line #{start_line+1} is #{method_length} lines long"
          end
        end

        # Check for deep nesting
        nest_level = 0
        max_nest = 0

        lines.each do |line|
          nest_level += 1 if line.match(/\s+if|\s+unless|\s+do|\s+case/)
          nest_level -= 1 if line.match(/\s+end\b/)
          max_nest = nest_level if nest_level > max_nest
        end

        if max_nest > 3
          issues << "- #{File.basename(file)}: Contains deeply nested code (#{max_nest} levels)"
        end
      end
    end

    if issues.empty?
      "✅ No obvious complexity issues detected."
    else
      "🔶 Potential complexity issues:\n#{issues.join("\n")}\n\nConsider refactoring these methods to reduce complexity."
    end
  end

  def check_i18n_usage
    view_dir = File.join(options[:path], 'app', 'views')
    return "Could not find views directory" unless Dir.exist?(view_dir)

    issues = []

    # Check for hardcoded strings in views
    Dir.glob(File.join(view_dir, '**', '*.erb')).each do |view|
      content = File.read(view)

      # Check for strings that might need translation
      hardcoded_strings = content.scan(/>([A-Z][^<]{10,})</)

      if hardcoded_strings.length > 3
        issues << "- #{File.basename(view)}: Contains #{hardcoded_strings.length} potentially hardcoded strings"
      end
    end

    # Check if locales directory exists and has files
    locales_dir = File.join(options[:path], 'config', 'locales')
    if !Dir.exist?(locales_dir) || Dir.glob(File.join(locales_dir, '*.yml')).empty?
      issues << "- No locale files found in config/locales"
    end

    if issues.empty?
      "✅ Basic I18n setup detected."
    else
      "🔶 I18n issues:\n#{issues.join("\n")}\n\nConsider using I18n.t() for user-facing strings."
    end
  end
end

# Run the code review if this file is executed directly
if __FILE__ == $0
  begin
    CodeReviewAutomation.new.run
  rescue => e
    puts "Error: #{e.message}".red
    puts e.backtrace.join("\n").red if ENV['DEBUG']
    exit 1
  end
end
