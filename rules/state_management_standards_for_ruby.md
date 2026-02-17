# State Management Standards for Ruby

> From [CodingRules.ai](https://codingrules.ai/rules/state-management-standards-for-ruby)

**Tags:** Ruby

---

# State Management Standards for Ruby

This document outlines the standards for managing state in Ruby applications. It covers approaches to managing application state, data flow, reactivity, and how these principles apply specifically to Ruby. It also includes modern approaches and patterns based on the latest Ruby version and features.

## 1. Introduction to State Management in Ruby

State management involves controlling and maintaining the application's data over time. In Ruby, this can range from simple variable assignments within a class to complex data flows in web applications using frameworks like Rails. Effective state management enables predictable application behavior, easier debugging, and improved performance.

### 1.1 Types of State

Understanding different types of state is crucial:

*   **Local State:** State confined to a specific method, block, or object instance.
*   **Application State:** State shared across multiple parts of the application, accessible by different objects.
*   **Persistent State:** State stored in a database or other form of persistent storage.
*   **UI State:** State that manages the visual elements and user interactions in a graphical interface.

### 1.2 Managing Complexity

As applications grow, state management becomes more complex. Poorly managed state can lead to:

*   **Bugs:** Difficult to reproduce or trace due to unpredictable state changes.
*   **Performance Issues:** Unnecessary state updates or inefficient data access.
*   **Maintainability Problems:** Code that is hard to understand, modify, or extend.

## 2. General Principles

These principles guide state management in Ruby applications.

*   **Single Source of Truth:** Define and maintain a single, authoritative source for each piece of data.

    *   **Do This:** Ensure that a particular piece of information has one clearly defined origin. Avoid duplication of data.
    *   **Don't Do This:** Store the same information in multiple, unsynchronized locations.
    *   **Why:** Reduces inconsistencies and simplifies updates. Improves data integrity.
*   **Immutability:** Prefer immutable data structures when possible.

    *   **Do This:** Use "freeze" to make objects immutable after initialization.
    *   **Don't Do This:** Mutate objects directly when the original value is still needed.
    *   **Why:** Simplifies reasoning about state changes and prevents unintended side effects.
*   **Explicit State Transitions:** Clearly define how the application moves from one state to another.

    *   **Do This:** Use state machines or similar patterns to model state transitions explicitly.
    *   **Don't Do This:** Implicitly change state through loosely coupled actions.
    *   **Why:** Improves traceability and control over application behavior.
*   **Minimize Shared State:** Reduce the amount of state shared between different parts of the application.

    *   **Do This:** Use dependency injection to isolate components and pass necessary state explicitly.
    *   **Don't Do This:** Rely on global variables or shared mutable objects.
    *   **Why:** Reduces coupling and makes components more independent and reusable.

## 3. State Management Techniques in Ruby

### 3.1 Local State

Local state resides within methods or object instances. Proper scoping and encapsulation are crucial.

*   **Variables:** Use local variables for temporary data.

    """ruby
    def calculate_area(width, height)
      area = width * height # local variable
      puts "Area: #{area}"
      area
    end
    """
*   **Instance Variables:** Store object-specific data.

    """ruby
    class Rectangle
      def initialize(width, height)
        @width = width  # instance variable
        @height = height # instance variable
      end

      def area
        @width * @height
      end
    end
    """
*   **Encapsulation:** Restrict access to internal state using "private" and "protected" access modifiers.

    """ruby
    class BankAccount
      def initialize(balance)
        @balance = balance
      end

      def deposit(amount)
        @balance += amount
      end

      def withdraw(amount)
        @balance -= amount if amount <= @balance
      end

      private   # Restrict direct access

      def current_balance
        @balance
      end
    end
    """

### 3.2 Application State Management

Managing global state requires careful consideration.

*   **Global Variables:** Avoid direct use of "$global_variables". They can lead to naming conflicts and unpredictable behavior.

    *   **Don't Do This:**

        """ruby
        $app_name = "My Application" # Avoid
        """
*   **Constants:** Suitable for immutable configuration values.

    """ruby
    APP_VERSION = "1.2.3"
    """
*   **Singleton Pattern:** Ensure a single instance of a class with global access.

    """ruby
    require 'singleton'

    class Configuration
      include Singleton

      attr_accessor :settings

      def initialize
        @settings = {}
      end
    end

    # Usage
    Configuration.instance.settings[:api_key] = "YOUR_API_KEY"
    puts Configuration.instance.settings[:api_key]
    """
    *   **Why:** Provides a controlled way to access shared state.
*   **Dependency Injection:** Pass dependencies explicitly to avoid tight coupling and make classes testable.

    """ruby
    class ReportGenerator
      def initialize(data_source)
        @data_source = data_source
      end

      def generate
        data = @data_source.fetch_data
        # ... generate report
      end
    end

    # Usage
    data_source = DatabaseDataSource.new
    report_generator = ReportGenerator.new(data_source)
    report_generator.generate
    """
*   **Service Objects:** Encapsulate business logic and manage related state transitions.

    """ruby
    class CreateUserService
      def call(params)
        user = User.new(params)
        if user.save
          # ... send welcome email, etc.
          Result.new(success: true, user: user)
        else
          Result.new(success: false, errors: user.errors)
        end
      end
    end

    # Usage
    result = CreateUserService.new.call(name: "John Doe", email: "john@example.com")
    if result.success?
      puts "User created: #{result.user.name}"
    else
      puts "Error: #{result.errors.full_messages.join(', ')}"
    end
    """

### 3.3 Persistent State Management

For data that needs to be stored and retrieved, databases are typically used.

*   **Active Record:** Rails' ORM handles much of the persistence logic.

    *   **Do This:** Define models with appropriate attributes and validations.
    *   **Don't Do This:** Bypass the ORM for common database operations without a compelling reason.
    """ruby
    class User < ApplicationRecord
      validates :email, presence: true, uniqueness: true

      has_many :posts
    end
    """
*   **Data Migrations:** Use migrations to manage database schema changes.

    *   **Do This:** Write idempotent migrations that can be run multiple times without errors.
    *   **Don't Do This:** Manually modify database schemas without a migration.

### 3.4 Concurrency and State

Managing state concurrently requires special attention.

*   **Threads:** Ruby's native threads are limited by the Global Interpreter Lock (GIL). Prefer using them for I/O-bound tasks. For CPU-bound parallel processing, consider using processes.

    """ruby
    threads = []
    10.times do |i|
      threads << Thread.new(i) do |thread_num|
        puts "Thread #{thread_num}: Starting"
        sleep(rand(1..3)) # Simulate some work
        puts "Thread #{thread_num}: Finishing"
      end
    end

    threads.each(&:join)
    puts "All threads finished."
    """
*   **Mutexes:** Use mutexes to protect shared state from concurrent access.

    """ruby
    require 'thread'

    class Counter
      def initialize
        @count = 0
        @mutex = Mutex.new
      end

      def increment
        @mutex.synchronize do
          @count += 1
        end
      end

      def value
        @count
      end
    end

    counter = Counter.new

    threads = []
    10.times do
      threads << Thread.new do
        1000.times do
          counter.increment
        end
      end
    end

    threads.each(&:join)
    puts "Counter value: #{counter.value}"
    """
*   **Actors:** The "Celluloid" gem provides an actor model for concurrent state management.

    *   **Why:** Actors provide a higher-level abstraction for concurrency, reducing the risk of race conditions and deadlocks.

## 4. State Management in Rails

Rails offers several mechanisms for managing state.

### 4.1 ActiveRecord Models

Models encapsulate the state of individual records in the database.

*   **Attributes:** Define attributes to represent the column values of a database table.
*   **Associations:** Manage relationships between different models.
*   **Callbacks:** Trigger actions before or after state changes (e.g., before_save, after_create). Use these judiciously as they can introduce hidden side effects and make debugging harder.

"""ruby
class Article < ApplicationRecord
  belongs_to :author
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { minimum: 5 }

  before_save :normalize_title

  private

  def normalize_title
    self.title = title.titleize
  end
end
"""

### 4.2 Sessions

Sessions store data related to a specific user across multiple requests.

*   **Cookies:** Sessions are typically implemented using cookies.
*   **Security:** Protect session data by setting secure and HttpOnly flags on cookies.
*   **Storage:** Rails supports various session storage options (e.g., cookies, database, memcached). Consider the performance and security implications of each option.

"""ruby
# Setting a session value
session[:user_id] = user.id

# Retrieving a session value

user_id = session[:user_id]

# Clearing a session value

session[:user_id] = nil

# Resetting the entire session

reset_session
"""

### 4.3 Caching

Caching improves performance by storing frequently accessed data in memory.

*   **Fragment Caching:** Cache parts of a view.

    """erb
    <% cache @article do %>
      <%= render @article %>
    <% end %>
    """
*   **Action Caching:** Cache the entire response of an action.
*   **Low-Level Caching:** Use the "Rails.cache" API for more granular control.

    """ruby
    Rails.cache.fetch("article:#{@article.id}", expires_in: 12.hours) do
      @article.content
    end
    """

### 4.4 Query Objects

Encapsulate complex database queries to keep controllers and models clean.

"""ruby
class ArticlesByAuthorQuery
  def initialize(author)
    @author = author
  end

  def call
    Article.where(author: @author).published.order(created_at: :desc)
  end
end

# Usage

articles = ArticlesByAuthorQuery.new(current_user).call
"""

### 4.5 State Machines

For models with complex state transitions, use a state machine gem like "aasm" or "statesman".

"""ruby
class Order < ApplicationRecord
  include AASM

  aasm column: :state do # default column: aasm_state
    state :pending, initial: true
    state :processing
    state :shipped
    state :delivered
    state :cancelled

    event :process do
      transitions from: :pending, to: :processing
    end

    event :ship do
      transitions from: :processing, to: :shipped
    end

    event :deliver do
      transitions from: :shipped, to: :delivered
    end

     event :cancel do
      transitions from: [:pending, :processing], to: :cancelled
    end
  end
end
"""

## 5. Modern Approaches

Using more contemporary design patterns can drastically improve state in Ruby web applications and APIs.

### 5.1 Redux/Flux-inspired patterns

While direct ports of Javascript frameworks like Redux or Flux are not common in Ruby (largely because Ruby is often server-side), the underlying principles of unidirectional data flow and centralized state management can be valuable.

*   **Centralized Store:**  A single source of truth for application state.  This is often implemented as a Ruby class or module.
*   **Actions:** Plain Ruby objects (or classes representing commands) that describe an intent to change the state.
*   **Reducers:** Pure functions that take the current state and an action and return the new state.  These should be free of side effects.
*   **Subscriptions:** Mechanisms for components to be notified when the state changes. This allows parts of the application to react to state updates.

"""ruby
# Example (simplified)

# Central Store

class AppStore
  attr_reader :state

  def initialize
    @state = { count: 0 } # Initial state
    @listeners = []
  end

  def dispatch(action)
    @state = reducer(@state, action)
    publish_changes
  end

  def subscribe(listener)
    @listeners << listener
  end

  private

  def reducer(state, action)
    case action[:type]
    when 'INCREMENT'
      { count: state[:count] + 1 }
    when 'DECREMENT'
      { count: state[:count] - 1 }
    else
      state # Default: return current state
    end
  end

  def publish_changes
    @listeners.each { |listener| listener.call(@state) }
  end
end

# Example usage

store = AppStore.new

# Subscribe to state changes

store.subscribe(lambda { |state| puts "Count updated: #{state[:count]}" })

# Dispatch actions

store.dispatch({ type: 'INCREMENT' }) # Output: Count updated: 1
store.dispatch({ type: 'DECREMENT' }) # Output: Count updated: 0

"""

*   **Benefits:** Highly predictable state updates, easier debugging, improved testability.
*   **Drawbacks:** More boilerplate code, can be overkill for very simple applications.

### 5.2 Event Sourcing

Instead of storing the current state of an application entity directly, event sourcing stores a sequence of events that represent changes to the state. The current state can be derived by replaying these events.

*   **Events:** Immutable records of something that happened in the application (e.g., "OrderCreated", "ItemAddedToCart").
*   **Event Store:** A database or specialized storage system for persisting events.
*   **Projections:**  Code that consumes events to build a read-optimized view of the data. This decouples the write (event) side from the read side.
*   **Benefits:** Auditability, temporal queries (e.g., "What was the state of the order 2 days ago?"), easier debugging of complex state transitions, ability to rebuild state accurately
*   **Drawbacks:** Increased complexity, requires a different mindset, potentially more read-side performance challenges

### 5.3 CQRS (Command Query Responsibility Segregation)

Separates read and write operations, improving performance and scalability.

*   **Commands:** Objects that represent an intent to change the state.
*   **Queries:** Objects that retrieve data without modifying the state.
*   **Benefits:** Optimized read and write paths, improved performance, better scalability, simplified data models.
*   **Drawbacks:** Increased complexity, requires careful design.

## 6. Anti-Patterns

Avoid these common pitfalls.

*   **God Classes:** Classes that manage too much state and logic.

    *   **Do This:** Break down large classes into smaller, more focused classes.
    *   **Don't Do This:** Keep adding responsibilities to a single class.
*   **Shotgun Surgery:** Making changes to multiple unrelated parts of the code to achieve a single goal.

    *   **Do This:** Refactor code to reduce dependencies and improve cohesion.
    *   **Don't Do This:** Scatter changes across the codebase.
*   **Global State Abuse:** Over-reliance on global variables or mutable shared objects.

    *   **Do This:** Use dependency injection or service objects to manage dependencies.
    *   **Don't Do This:** Directly access global state from multiple parts of the application.
*   **Ignoring Immutability:**  Mutating objects when the original value is still needed.

    *   **Do This:** Use immutable data structures or defensive copying.
    *   **Don't Do This:** Modify objects in place.

## 7. Conclusion

Effective state management is crucial for building maintainable, scalable, and reliable Ruby applications. By following these standards and best practices, developers can manage state effectively, reduce bugs, and improve application performance. Use the right tool for the job, and continuously refine your state management strategies as your application evolves.
