# Core Architecture Standards for Ruby

> From [CodingRules.ai](https://codingrules.ai/rules/core-architecture-standards-for-ruby)

**Tags:** Ruby

---

# Core Architecture Standards for Ruby

This document outlines the core architectural standards for Ruby projects, focusing on maintainability, performance, and security. These standards are designed to guide development teams and provide context for AI coding assistants to generate high-quality, consistent Ruby code. This standard is tailored specifically to the latest version of Ruby and emphasizes modern best practices.

## 1. Architectural Patterns

### 1.1 Model-View-Controller (MVC)

**Standard:** Adopt the MVC architectural pattern for web applications.

*   **Do This:** Structure your application into Models (data and logic), Views (presentation), and Controllers (handling user input and interactions).
*   **Don't Do This:** Avoid tightly coupling Models, Views, and Controllers. Fat models, skinny controllers are generally preferred.

**Why:** MVC promotes separation of concerns, making applications more maintainable, testable, and scalable.

**Code Example (Rails MVC):**

"""ruby
  # app/models/user.rb
  class User < ApplicationRecord
    validates :email, presence: true, uniqueness: true
    has_many :posts
  end

  # app/views/users/show.html.erb
  <h1><%= @user.email %></h1>
  <% @user.posts.each do |post| %>
    <p><%= post.title %></p>
  <% end %>

  # app/controllers/users_controller.rb
  class UsersController < ApplicationController
    def show
      @user = User.find(params[:id])
    end
  end
"""

**Anti-Pattern:** Placing business logic directly within views or controllers, leading to code duplication and making the application difficult to reason about.

### 1.2 Service Objects

**Standard:** Encapsulate complex business logic into Service Objects.

*   **Do This:** Create dedicated classes to handle specific business operations, keeping controllers lean.
*   **Don't Do This:** Put complex logic directly within models or controllers.

**Why:** Service Objects promote code reusability, testability, and maintainability by isolating specific responsibilities.

**Code Example:**

"""ruby
  # app/services/user_creator.rb
  class UserCreator
    def initialize(params)
      @params = params
    end

    def call
      user = User.new(@params)
      if user.save
        # Send welcome email
        UserMailer.welcome_email(user).deliver_later
        user
      else
        false
      end
    end
  end

  # app/controllers/users_controller.rb
  class UsersController < ApplicationController
    def create
      user = UserCreator.new(params[:user]).call
      if user
        redirect_to user_path(user), notice: 'User created successfully'
      else
        render :new, status: :unprocessable_entity
      end
    end
  end
"""

**Anti-Pattern:** Overloading models with unrelated business logic, leading to "fat models" that are hard to maintain.

### 1.3 Event-Driven Architecture

**Standard:** Use an event-driven architecture for asynchronous tasks and decoupled components.

*   **Do This:** Implement background processing using tools such as Sidekiq, Resque, or ActiveJob. Utilize Ruby's "concurrent" gem or standard "Thread" class for threading. Utilize "Hanami::Events" or "wisper´ for in-process events.
*   **Don't Do This:** Perform long-running tasks within the request-response cycle.

**Why:** Event-driven architecture improves application responsiveness and scalability by offloading tasks to background processes.

**Code Example (Sidekiq):**

"""ruby
  # app/workers/email_worker.rb
  class EmailWorker
    include Sidekiq::Worker

    def perform(user_id)
      user = User.find(user_id)
      UserMailer.welcome_email(user).deliver_now
    end
  end

  # app/controllers/users_controller.rb
  class UsersController < ApplicationController
    def create
      user = User.new(params[:user])
      if user.save
        EmailWorker.perform_async(user.id) # Enqueue the email sending
        redirect_to user_path(user), notice: 'User created successfully'
      else
        render :new, status: :unprocessable_entity
      end
    end
  end
"""

**Anti-Pattern:** Blocking the main application thread with synchronous tasks, leading to poor user experience.

### 1.4 API-First Design

**Standard:** Design applications with an API-first approach.

*   **Do This:** Define clear API contracts (e.g., using OpenAPI/Swagger) before implementing the UI or other client-facing components.
*   **Don't Do This:** Build APIs as an afterthought or directly tied to the UI.

**Why:** API-first design promotes reusability, interoperability, and scalability by decoupling the backend from the frontend.

**Code Example (Rails API mode):**

"""ruby
  # config/routes.rb
  Rails.application.routes.draw do
    namespace :api do
      namespace :v1 do
        resources :users, only: [:index, :show, :create, :update, :destroy]
      end
    end
  end

  # app/controllers/api/v1/users_controller.rb
  module Api
    module V1
      class UsersController < ApplicationController
        def index
          @users = User.all
          render json: @users
        end

        # ... other actions
      end
    end
  end
"""

**Anti-Pattern:** Creating tightly coupled APIs that are difficult to evolve independently.

## 2. Project Structure and Organization

### 2.1 Directory Structure

**Standard:** Follow a consistent and logical directory structure.

*   **Do This:** Organize code into "app", "lib", "config", "db", "spec" (or "test") directories.
*   **Don't Do This:** Scatter files randomly throughout the project.

**Why:** A well-defined directory structure improves code discoverability, maintainability, and collaboration.

**Example:**

"""
  my_project/
  ├── app/
  │   ├── models/
  │   ├── views/
  │   ├── controllers/
  │   ├── services/
  │   ├── mailers/
  │   └── helpers/
  ├── lib/
  │   └── my_gem/        # External libraries & utilities
  ├── config/
  │   ├── routes.rb
  │   ├── application.rb
  │   └── database.yml
  ├── db/
  │   ├── migrate/
  │   └── seeds.rb
  ├── spec/              # or test/
  │   ├── models/
  │   ├── controllers/
  │   └── support/
  ├── Gemfile
  ├── README.md
  └── .gitignore
"""

**Anti-Pattern:** Putting unrelated code in a single directory, making it difficult to find and understand.

### 2.2 Module Organization

**Standard:** Use modules to group related classes and functions.

*   **Do This:** Create modules to encapsulate related functionality and prevent namespace collisions.
*   **Don't Do This:** Define global functions or classes without proper namespacing.

**Why:** Modules improve code organization, readability, and maintainability.

**Code Example:**

"""ruby
  # lib/payment_gateway.rb
  module PaymentGateway
    class Client
      def self.charge(amount, credit_card)
        # ... implementation
      end
    end

    module Adapters
      class Stripe
        def self.charge(amount, token)
          # ... Stripe specific impl
        end
      end
    end
  end

  # Usage
  PaymentGateway::Client.charge(100, credit_card_info)
  PaymentGateway::Adapters::Stripe.charge(100, stripe_token)

"""

**Anti-Pattern:** Defining global classes or functions that can clash with other libraries or code.

### 2.3 Dependency Injection

**Standard:** Utilize dependency injection to decouple components.

*   **Do This:** Pass dependencies into classes or functions instead of hardcoding them.
*   **Don't Do This:** Create tight coupling through global variables or direct instantiation of dependencies within classes.

**Why:** Dependency injection increases code testability and flexibility by allowing dependencies to be easily swapped or mocked.

**Code Example:**

"""ruby
  # Injecting a logger dependency
  class MyService
    def initialize(logger:)
      @logger = logger
    end

    def do_something
      @logger.info "Doing something..."
      # ... implementation
    end
  end

  # Usage with different loggers
  my_service = MyService.new(logger: Logger.new($stdout))
  my_service.do_something

  my_service = MyService.new(logger: MockLogger.new) # For testing Purposes
  my_service.do_something
"""

**Anti-Pattern:** Hardcoding dependencies within classes, making it difficult to test or reuse them in different contexts.

## 3. Code-Level Standards

### 3.1 Naming Conventions

**Standard:** Follow consistent naming conventions.

*   **Do This:** Use descriptive names for classes, methods, and variables. Use snake_case for variables and methods, PascalCase for classes and modules.
*   **Don't Do This:** Use cryptic or ambiguous names.

**Why:** Clear naming improves code readability and understanding.

**Code Example:**

"""ruby
  class UserProfile   #  Use PascalCase for Class Names
    def calculate_age  # Use snake_case for method names
      @date_of_birth  # Example of a variable name
    end
  end

  # Avoid:
  # class UP
  # def calc
  # x = ...
"""

**Anti-Pattern:** Using single-letter variable names or unclear abbreviations.

### 3.2 Modularity

**Standard:** Write modular code.

*   **Do This:** Break down complex methods into smaller, self-contained functions.
*   **Don't Do This:** Write long, monolithic functions that are difficult to understand and test.

**Why:** Modular code improves readability, testability, and reusability.

**Code Example:**

"""ruby
  def process_order(order)
    validate_order(order)
    calculate_total(order)
    charge_customer(order)
    send_confirmation_email(order)
  end

  private

  def validate_order(order)
    # ... validation logic
  end

  def calculate_total(order)
    # ... calculation logic
  end

  # ... other private methods
"""

**Anti-Pattern:** Writing large, complex methods that perform multiple unrelated tasks.

### 3.3 Error Handling

**Standard:** Implement robust error handling mechanisms.

*   **Do This:** Use "begin...rescue...end" blocks to handle exceptions. Raise exceptions when necessary.
*   **Don't Do This:** Ignore exceptions or swallow errors silently.

**Why:** Proper error handling prevents application crashes and provides meaningful feedback to users.

**Code Example:**

"""ruby
  def process_file(filename)
    begin
      file = File.open(filename)
      # ... process file
    rescue Errno::ENOENT => e
      Rails.logger.error "File not found: #{e.message}"
      # Raise a custom exception or return an error status.
      raise CustomFileNotFoundError, "File not found: #{filename}"
    rescue StandardError => e
      Rails.logger.error "An unexpected error occurred: #{e.message}"
      # Handle other errors appropriately
    ensure
      file.close if file # Ensure file close to prevent resource leaks
    end
  end
"""

**Anti-Pattern:** Ignoring exceptions or using bare "rescue" blocks without specifying the exception type.

### 3.4 Performance Optimization

**Standard:** Optimize code for performance.  Use tools such as "benchmark", "memory_profiler" or "flamegraph" to assist!

*   **Do This:** Use efficient data structures and algorithms. Avoid unnecessary database queries.  Consider using caching strategies via Rails built-in caching or external caches like Redis.
*   **Don't Do This:** Write code that performs poorly or consumes excessive resources. Premature optimization!

**Why:** Performance optimization improves application responsiveness and scalability.

**Code Example:**

"""ruby
  # Instead of:
  users.each { |user| puts user.name }

  # Use map(&:name) for performance:
  names = users.map(&:name) # More efficient as you pre-allocate memory for a dedicated array

  # SQL Optimization
  # Instead of:
  orders.each { |order| puts order.customer.name } # N+1 query problem

  # Use includes to eager load associations:
  orders = Order.includes(:customer)
  orders.each { |order| puts order.customer.name } # Reduces database queries
"""

**Anti-Pattern:** Ignoring performance issues or writing inefficient code with little to no thought of optimization.

### 3.5 Security Considerations

**Standard:** Implement security best practices.

*   **Do This:** Sanitize user input. Protect against SQL injection, cross-site scripting (XSS), and other common vulnerabilities. Utilize tools like Brakeman for static analysis.
*   **Don't Do This:** Store sensitive data in plain text.

**Why:** Security best practices protect the application and its users from threats.

**Code Example:**

"""ruby
  # Sanitize user input
  params[:search_term] = ActionController::Base.helpers.sanitize(params[:search_term])

  # Use parameterized queries to prevent SQL injection
  User.where("email = ?", params[:email])

  # Use bcrypt for password hashing
  def password=(new_password)
    @password = BCrypt::Password.create(new_password)
    self.password_hash = @password
  end
"""

**Anti-Pattern:** Storing passwords in plain text or failing to sanitize user input.

## 4. Specific Ruby Features (Latest Version)

### 4.1 Pattern Matching

**Standard:** Utilize pattern matching for concise and expressive code.

*   **Do This:** Use "case...in" statements to match complex data structures.
*   **Don't Do This:** Rely solely on traditional "if...else" statements for complex conditional logic.

**Why:** Pattern matching simplifies complex conditional logic and makes code more readable.

**Code Example:**

"""ruby
  result = {status: :ok, data: {name: "John", age: 30}}

  case result
  in {status: :ok, data: {name: String => name, age: Integer => age}}
    puts "Name: #{name}, Age: #{age}"
  in {status: :error, message: String => message}
    puts "Error: #{message}"
  else
    puts "Unknown result"
  end
"""

**Anti-Pattern:** Missing opportunities to use powerful pattern matching features in suitable situations.

### 4.2 Fiber Scheduler/Concurrency

**Standard:** Use fibers for concurrent code execution

*   **Do This:** Use "Fiber.schedule" to execute functions concurrently without native threads.
*   **Don't Do This:** Use many OS-level threads unless specifically needed.

**Why:** Fibers greatly improve concurrency performance.

**Code Example:**

"""ruby
Fiber.schedule do
  # concurrent code!
  puts "Running in a fiber!"
end
"""

**Anti-Pattern:** Ignoring the existance and performance benefits of fibers.

### 4.3 Ractor

**Standard**: Use Ractor for parallel code execution.

*   **Do This**: Isolate state between "Ractor"s to avoid data races.
*   **Don't Do This**: Share mutable state directly between "Ractor"s.

**Why**: Helps achieve true parallelism in Ruby code.

**Code Example:**

"""ruby
  r = Ractor.new { puts "Hello from a ractor!" }
  r.take #=> "Hello from a ractor!"
"""

**Anti-Pattern**: Sharing mutable data between actors without synchronization.

## 5. Tooling and Automation

### 5.1 Linters and Code Analysis

**Standard:** Use Linters (Rubocop), Security Scanners (Brakeman) and code analysis tools

*   **Do This:** Configure Rubocop with a configuration file (".rubocop.yml") to enforce the coding standards defined in this document.
*   **Do This:** Integrate Brakeman into the CI/CD pipeline.
*   **Don't Do This:** Ignore warnings from the linter and static analysis tools.

### 5.2 Testing Framework

**Standard**: Implement automated test suites using RSpec or Minitest

*   **Do This**: Aim for high test coverage. Write unit, integration and end-to-end tests.
*   **Don't Do This**: Skip writing tests or commit code with failing tests.

### 5.3 Continuous Integration & Continuous Deployment (CI/CD)

**Standard:** Use CI/CD pipelines for automated builds, tests, and deployments.

*   **Do This:** Integrate the CI/CD pipeline with code repositories (e.g., GitHub, GitLab).
*   **Don't Do This:** Deploy code manually without automated testing or validation.

**Why:** CI/CD automates the software development lifecycle, resulting in faster delivery, fewer bugs, and higher quality.

**Code Example (GitHub Actions):**

"""yaml
  # .github/workflows/main.yml
  name: Ruby CI

  on:
    push:
      branches: [ main ]
    pull_request:
      branches: [ main ]

  jobs:
    test:
      runs-on: ubuntu-latest
      services:
        postgres:
          image: postgres:13
          ports: ['5432:5432']
          env:
            POSTGRES_USER: ruby
            POSTGRES_PASSWORD: password
            POSTGRES_DB: test_db
          options: >-
            --health-cmd pg_isready
            --health-interval 10s
            --health-timeout 5s
            --health-retries 5
      steps:
      - uses: actions/checkout@v2
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2   # specify version of Ruby to use (eg: 2.7.2)
          bundler-cache: true  # runs 'bundle install' and caches installed gems automatically

      - name: Configure application
        run: cp config/database.yml.example config/database.yml

      - name: Create and Migrate Database
        run: |
          bundle exec rails db:create
          bundle exec rails db:migrate

      - name: Run tests
        run: bundle exec rspec
"""

This comprehensive document provides a foundation for building robust, maintainable, and high-performing Ruby applications, aligning with the latest features and best practices of the language.
