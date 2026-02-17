# Deployment and DevOps Standards for Ruby

> From [CodingRules.ai](https://codingrules.ai/rules/deployment-and-devops-standards-for-ruby)

**Tags:** Ruby

---

# Deployment and DevOps Standards for Ruby

This document outlines the deployment and DevOps standards for Ruby projects, aiming to create robust, maintainable, and scalable applications. It covers build processes, CI/CD pipelines, production considerations, and relevant technologies specific to the Ruby ecosystem.

## 1. Build Processes and Dependency Management

### 1.1 Dependency Management with Bundler

Bundler is the standard dependency manager for Ruby projects. Using it correctly ensures consistent environments across development, testing, and production.

**Do This:** Always use Bundler to manage your project's dependencies.

**Don't Do This:** Manually install gems or rely on system-installed gems for production deployments.

**Why:** Using Bundler guarantees that all environments use the exact same gem versions, preventing "it works on my machine" issues.

**Example:**

"""ruby
# Gemfile

source 'https://rubygems.org'

gem 'rails', '~> 7.0'
gem 'pg'
gem 'puma'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

group :development do
  gem 'web-console'
end
"""

*   **Actionable Standard:** Ensure a "Gemfile" and "Gemfile.lock" are present in your project.  The "Gemfile.lock" MUST be committed to version control.
*   **Actionable Standard:** Use "bundle install" for installing dependencies.  Run "bundle update" judiciously to update gem versions and test thoroughly.
*   **Actionable Standard:** Configure Bundler to install gems into a "vendor/bundle" directory or use a system-wide gemset via "rvm" or "rbenv".
*   **Actionable Standard:** Employ "bundle exec" when running executables like "rails server" or "rake db:migrate" to ensure they use the gems specified in the "Gemfile".

**Anti-pattern:** Forgetting to run "bundle install" after cloning a repository or after modifying the "Gemfile". This can lead to missing dependencies and runtime errors.

### 1.2 Build Automation with Rake

Rake is a Ruby-based build tool, similar to Make in other languages. Use it for automating common tasks such as database migrations, asset compilation, and code analysis.

**Do This:** Define Rake tasks for common deployment and maintenance tasks.

**Don't Do This:** Manually execute deployment steps or rely on scripts scattered throughout the project.

**Why:** Rake provides a consistent and repeatable way to perform tasks, reducing the risk of human error during deployments.

**Example:**

"""ruby
# Rakefile

require 'rake'
require 'rake/tasklib'

namespace :deploy do
  desc "Deploy to production"
  task :production do
    puts "Deploying to production..."
    # Add deployment steps here
  end

  desc "Migrate the database"
  task :migrate do
    puts "Migrating the database..."
    sh 'bundle exec rails db:migrate' # Correct use of bundle exec
  end
end
"""

*   **Actionable Standard:** Create a "Rakefile" to define your project's build and deployment tasks.
*   **Actionable Standard:** Use namespaces to organize related tasks (e.g., "deploy:production", "db:migrate").
*   **Actionable Standard:** Utilize shell commands (e.g., "sh", "exec") within Rake tasks to execute system commands.  Always use "bundle exec" prefix.
*   **Actionable Standard:** Document each Rake task with a descriptive "desc" for clarity.

**Anti-Pattern:** Manually running database migrations on production servers can lead to inconsistencies and errors, especially in multi-server environments. Automate these tasks using Rake.

## 2. Continuous Integration and Continuous Deployment (CI/CD)

### 2.1 CI/CD Pipeline Setup

A CI/CD pipeline automates the process of building, testing, and deploying your Ruby application.  Popular CI/CD tools include Jenkins, GitLab CI, GitHub Actions, CircleCI, and Travis CI.

**Do This:** Integrate your Ruby project with a CI/CD pipeline.

**Don't Do This:** Manually build, test, and deploy your application each time you make changes.

**Why:** CI/CD reduces deployment risks, speeds up the development process, and ensures that code is always in a deployable state.

**Example (GitHub Actions):**

"""yaml
# .github/workflows/main.yml
name: Ruby CI/CD

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:13
        ports: ['5432:5432']
        env:
          POSTGRES_USER: postgres
          POSTGRES_DB: your_app_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2 # Example Ruby version
          bundler-cache: true
      - name: Install dependencies
        run: bundle install
      - name: Set up database
        run: |
          bundle exec rails db:create
          bundle exec rails db:schema:load
      - name: Run tests
        run: bundle exec rspec

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main' # Only deploy from main
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Heroku
        uses: akhileshns/heroku-deploy@v3.12.12 # Use specific version
        with:
          heroku_api_key: ${{secrets.HEROKU_API_KEY}}
          heroku_app_name: your-heroku-app
          heroku_email: your-email@example.com
"""

*   **Actionable Standard:** Define CI/CD pipelines in YAML files (e.g., ".gitlab-ci.yml", ".github/workflows/main.yml").
*   **Actionable Standard:** Automate the following steps in the pipeline: code checkout, dependency installation, code linting (using RuboCop), running tests (unit, integration, system), and deployment.
*   **Actionable Standard:** Use environment variables for sensitive information like API keys, database passwords, and deployment credentials. Store these secrets securely via the CI/CD platform's secrets management.
*   **Actionable Standard:** Implement automated rollbacks in case of deployment failures.

**Anti-pattern:** Skipping automated tests in the CI/CD pipeline can lead to deploying broken code to production, causing downtime and user frustration.

### 2.2 Code Analysis and Linting

RuboCop is a popular static code analyzer and formatter for Ruby. Using it helps enforce coding standards and identify potential code quality issues.

**Do This:** Integrate RuboCop into your CI/CD pipeline.

**Don't Do This:** Ignore RuboCop warnings or manually fix code style issues.

**Why:** RuboCop ensures consistent coding style, catches potential bugs, and maintains code quality, which is essential for maintainability.

**Example:**

"""yaml
# .github/workflows/main.yml (modified)

name: Ruby CI/CD

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
          bundler-cache: true
      - name: Install dependencies
        run: bundle install
      - name: Run RuboCop
        run: bundle exec rubocop
      - name: Set up database
        run: |
          bundle exec rails db:create
          bundle exec rails db:schema:load
      - name: Run tests
        run: bundle exec rspec
"""

*   **Actionable Standard:** Include a ".rubocop.yml" file in your project to configure RuboCop's rules and exclusions.
*   **Actionable Standard:** Customize RuboCop rules according to your team's coding conventions (e.g., line length, indentation).  Airbnb's Ruby style guide is also a good reference point.
*   **Actionable Standard:** Automatically fix RuboCop violations where possible using "rubocop -a".
*   **Actionable Standard:** If you choose to ignore specific RuboCop offenses, document the reason clearly in the code or ".rubocop.yml".

**Anti-pattern:** Disabling RuboCop entirely or ignoring its warnings undermines code quality and consistency.

## 3. Production Considerations

### 3.1 Application Servers – Puma and Unicorn

Puma and Unicorn are popular application servers for Ruby on Rails applications. Puma supports multi-threading due to Ruby's Global VM Lock (GVL) limitations, while Unicorn is a pre-forking server.

**Do This:** Choose an application server based on your application's requirements and infrastructure. Puma is generally recommended when using modern Ruby versions.

**Don't Do This:** Rely on the WEBrick server (the default in Rails development) for production deployments.

**Why:** Production-grade application servers like Puma and Unicorn are designed to handle high traffic, concurrency, and resource management, which WEBrick is not.

**Example (Puma Configuration):**

"""ruby
# config/puma.rb

workers Integer(ENV['WEB_CONCURRENCY'] || 2) # Number of worker processes
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000 # Utilize environment variable for port.
environment ENV['RAILS_ENV'] || 'development' # Set Rails environment
# On worker boot, add connections that pre-exist to the pool
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

before_fork do
  require 'puma_worker_killer'

  PumaWorkerKiller.config do |config|
    config.ram           = 1024 # mb
    config.frequency     = 5     # seconds
    config.percent_usage = 0.98
    config.rolling_restart_frequency = 6 * 3600 # 6 hours in seconds
    config.reaper_status_logs = true # setting this to false will not log lines like:
                                     # PumaWorkerKiller: Consuming 54.34765625 mb with master and 2 workers.

  end
  PumaWorkerKiller.start
end
"""

*   **Actionable Standard:** Configure Puma with the appropriate number of workers and threads based on your server's CPU cores and memory.
*   **Actionable Standard:** Use environment variables (e.g., "WEB_CONCURRENCY", "RAILS_MAX_THREADS", "PORT") to configure Puma in different environments.
*   **Actionable Standard:** Integrate Puma with a process manager like Systemd or Supervisor to ensure automatic restarts in case of crashes.
*   **Actionable Standard:** Consider using "puma-worker-killer" to automatically restart Puma workers that consume excessive memory.  Helps prevent memory leaks from crashing the entire server.

**Anti-pattern:** Statically defining the number of workers and threads in the Puma configuration file makes it difficult to adapt to different environments and server sizes.

### 3.2 Database Connection Pooling

Database connection pooling improves the performance of Ruby applications by reusing database connections instead of creating new ones for each request.

**Do This:** Configure database connection pooling in your "database.yml" file.

**Don't Do This:** Use a single database connection for all requests.

**Why:** Connection pooling reduces the overhead of establishing new database connections, which can be a significant bottleneck for high-traffic applications.

**Example:**

"""yaml
# config/database.yml

default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: your_username
  password: your_password

development:
  <<: *default
  database: your_app_development

test:
  <<: *default
  database: your_app_test

production:
  <<: *default
  database: your_app_production
  url: <%= ENV['DATABASE_URL'] %> # Use database URL from environment variables

"""

*   **Actionable Standard:** Set the "pool" size in "database.yml" to an appropriate value based on your application's concurrency and database server capacity. The pool size generally should be the same as the maximum number of threads you have configured for Puma or the expected total connections from all unicorn workers.
*   **Actionable Standard:**  Use a database URL format instead of hardcoding credentials directly inside "database.yml".
*   **Actionable Standard:**  Monitor your database connection usage to identify potential connection leaks or bottlenecks.

**Anti-pattern:** Not configuring database connection pooling can lead to slow response times and database server overload.

### 3.3 Logging and Monitoring

Proper logging and monitoring are crucial for understanding application behavior, identifying performance issues, and diagnosing errors.

**Do This:** Implement comprehensive logging and monitoring in your Ruby applications.

**Don't Do This:** Rely on "puts" statements for logging or ignore application metrics.

**Why:** Logging provides valuable insights into application behavior, while monitoring helps identify and diagnose performance issues and errors.

**Example (Logging with Rails):**

"""ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  before_action :log_request

  private

  def log_request
    Rails.logger.info "Request: #{request.method} #{request.path}" # Detailed logging
    Rails.logger.debug "Parameters: #{params.inspect}"
  end
end

# Using logger inside model

class User < ApplicationRecord
  after_create :log_creation

  private
  def log_creation
    Rails.logger.info "User created with id: #{self.id}"
  end
end

# In the console to log directly:

Rails.logger.info "Something happened here important"
"""

*   **Actionable Standard:** Use Rails' built-in logger ( "Rails.logger" ) for structured logging at different levels ( "debug", "info", "warn", "error", "fatal" ).
*   **Actionable Standard:** Log essential events, such as requests, database queries, errors, and background job executions.
*   **Actionable Standard:** Integrate with a centralized logging system like ELK Stack (Elasticsearch, Logstash, Kibana), Splunk, or Papertrail.
*   **Actionable Standard:** Implement application performance monitoring (APM) using tools like New Relic, Datadog, or Scout APM.  Focus on metrics like response time, throughput, error rates, and database query performance.
*   **Actionable Standard:** Use structured logging (e.g., JSON format) to faciliter parsing and analysis.
*   **Actionable Standard:** Monitor system-level metrics, such as CPU usage, memory usage, disk I/O, and network traffic.

**Anti-pattern:** Logging sensitive information like passwords or API keys can create security vulnerabilities. Implement proper redaction or masking of sensitive data in logs.

### 3.4 Security Best Practices

Security is paramount in production environments. The following security best practices are essential:

*   **Actionable Standard:** Keep Ruby, Rails, and all gems up-to-date with the latest security patches.  Automate this process where possible.
*   **Actionable Standard:** Follow secure coding practices to prevent common vulnerabilities like SQL injection, cross-site scripting (XSS), and cross-site request forgery (CSRF).
*   **Actionable Standard:** Use strong and unique passwords for all user accounts. Implement multi-factor authentication (MFA) where possible.
*   **Actionable Standard:** Enforce HTTPS for all communication to protect data in transit. Configure HSTS (HTTP Strict Transport Security) to prevent man-in-the-middle attacks.
*   **Actionable Standard:** Regularly review and update security configurations, including firewalls, intrusion detection systems, and access controls.

**Anti-pattern:** Ignoring security vulnerabilities or failing to apply security patches exposes applications to potential attacks.  Use tools like Bundler Audit to check for known vulnerabilities in your dependencies.

### 3.5 Environment Variables

Using environment variables for configuration ensures flexibility and security in different environments.

**Do This:** Store configuration settings (e.g., database credentials, API keys) in environment variables.

**Don't Do This:** Hardcode configuration settings in code or configuration files.

**Why:** Environment variables provide a secure and flexible way to configure applications without modifying code.

**Example:**

"""ruby
# config/database.yml (as shown previously)

production:
  <<: *default
  database: your_app_production
  url: <%= ENV['DATABASE_URL'] %>

# Rails secret key

# config/secrets.yml or config/credentials.yml.enc

secret_key_base: <%= ENV["SECRET_KEY_BASE"] %> #Example in older version of rails
"""

*   **Actionable Standard:** Use a gem like "dotenv" in development to load environment variables from a ".env" file.  *Never* commit the ".env" file to version control.
*   **Actionable Standard:**  Configure your deployment environment (e.g., Heroku, AWS) to set environment variables for production.
*   **Actionable Standard:** Employ a secrets management solution like HashiCorp Vault or AWS Secrets Manager to securely store and access sensitive environment variables.

**Anti-pattern:** Committing sensitive credentials to version control poses a significant security risk.

## 4. Containerization and Infrastructure as Code (IaC)

### 4.1 Docker and Containerization

Docker allows you to package your Ruby application and its dependencies into a standardized unit for software development.  This provides consistency across different environments.

**Do This:** Containerize your Ruby application using Docker.

**Don't Do This:** Deploy your application directly to virtual machines without containerization.

**Why:** Docker simplifies deployments, ensures consistency across environments, and improves resource utilization.

**Example (Dockerfile):**

"""dockerfile
# Dockerfile

FROM ruby:3.2-slim # Use a slim Ruby image
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 --without development test

COPY . .

# Add a script to be executed every time the container starts.

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000 # Example port
CMD ["rails", "server", "-b", "0.0.0.0"] #Or another production-appropriate command
"""

*   **Actionable Standard:** Create a "Dockerfile" to define the environment for your Ruby application.
*   **Actionable Standard:** Use multi-stage builds to reduce the size of the final Docker image by separating build dependencies from runtime dependencies when using interpreted languages like Ruby.
*   **Actionable Standard:** Utilize a ".dockerignore" file to exclude unnecessary files and directories from the Docker image (e.g., "log/", "tmp/", "test/").
*   **Actionable Standard:** Use Docker Compose for local development to manage multi-container applications (e.g., Rails app with a PostgreSQL database).

**Anti-pattern:** Building large Docker images with unnecessary dependencies increases deployment time and resource consumption.

### 4.2 Infrastructure as Code

Infrastructure as Code (IaC) involves managing and provisioning infrastructure through code rather than manual processes.  Terraform and CloudFormation are popular IaC tools.

**Do This:** Manage your infrastructure using IaC tools.

**Don't Do This:** Manually provision and configure servers.

**Why:** IaC automates infrastructure management, improves consistency, and enables infrastructure to be version controlled along with application code.

*   **Actionable Standard:** Define your infrastructure resources (e.g., servers, databases, networks) as code using Terraform, CloudFormation, or similar tools.
*   **Actionable Standard:** Store your IaC code in version control along with your application code.
*   **Actionable Standard:** Use CI/CD pipelines to automate infrastructure deployments and updates.

**Anti-pattern:** Manually configuring servers can lead to inconsistencies and configuration drift, making it difficult to manage and maintain infrastructure.

These standards provide a comprehensive guide for deploying and managing Ruby applications in production, ensuring robustness, scalability, and maintainability. By following these guidelines, development teams can improve their deployment processes, reduce risks, and deliver high-quality software.
