# Performance Optimization Standards for Ruby

> From [CodingRules.ai](https://codingrules.ai/rules/performance-optimization-standards-for-ruby)

**Tags:** Ruby

---

# Performance Optimization Standards for Ruby

This document outlines performance optimization standards for Ruby code. It aims to improve application speed, responsiveness, and resource usage by providing actionable guidelines and examples. We'll focus on modern Ruby practices and patterns, with an emphasis on the latest Ruby versions.

## I. Architectural Considerations

### 1. Choosing the Right Ruby Implementation

**Do This:** Use Ruby MRI (CRuby) or optimize your selection for specific performance needs based on your workload.

**Don't Do This:** Blindly use an implementation without considering its strengths and weaknesses.

**Why:** Different Ruby implementations offer varying performance characteristics.

*   **CRuby (MRI):** The standard implementation, generally well-optimized. Most gem compatibility.
*   **JRuby:** Runs on the JVM, providing benefits from the JVM's JIT compiler and garbage collector, and integration with Java libraries. Well-suited for I/O heavy operations and scenarios requiring Java interop.
*   **TruffleRuby:** An optimizing just-in-time (JIT) compiler built on GraalVM. Delivers significant speed improvements in CPU-bound applications but may have compatibility issues with some gems.
*   **RubyMotion:** (Not actively maintained) Compiles Ruby to native iOS and macOS applications. Not suitable for general purpose backend development.

**Code Example (Checking Ruby Implementation):**

"""ruby
puts RUBY_ENGINE # => "ruby" (for MRI), "jruby", "truffleruby" etc.
"""

### 2. Load Testing and Benchmarking

**Do This:** Load test your application under expected production traffic and benchmark critical code paths.

**Don't Do This:** Make performance assumptions without empirical evidence.

**Why:** Identifying bottlenecks early is crucial. Tools like "wrk", "ab", and "Benchmark" help find those areas.

**Code Example (Benchmarking):**

"""ruby
require 'benchmark'

n = 50000
Benchmark.bm do |x|
  x.report("string interpolation:") { n.times { "result: #{1 + 1}" } }
  x.report("string concatenation: ") { n.times { "result: " + (1 + 1).to_s } }
end

# Expected output:

#                         user     system      total        real

# string interpolation:  0.040485   0.000000   0.040485 (  0.040626)

# string concatenation:   0.072514   0.000000   0.072514 (  0.072675)

"""

### 3. Choosing the Right Framework

**Do This:** Carefully select a framework (e.g., Rails, Sinatra, Hanami) that aligns with your application's complexity and performance needs.

**Don't Do This:** Use a heavyweight solution for a lightweight job.

**Why:** Frameworks provide structure but impose overhead. Rails, the most popular framework, has conventions and features which can aid speed of development at the expense of runtime performance. For simple API applications, Sinatra or Hanami might be more performant choices.

### 4. Microservices vs. Monolith

**Do This:** For large complex systems, consider breaking down the system into microservices to improve scalability and fault isolation.

**Don't Do This:** Prematurely break down an application into microservices if this adds excessive overhead of network traffic and inter-service dependencies.

**Why:** Decoupling components enables independent scaling and deployment, optimizing resource allocation.

## II. Coding Practices

### 1. Minimize Object Creation

**Do This:** Reuse objects whenever possible, especially within loops. Use object pooling techniques for frequently used objects.

**Don't Do This:** Create excessive temporary objects, especially inside loops which can trigger frequent garbage collection.

**Why:** Object allocation is relatively expensive in Ruby. Reducing it can significantly improve performance.

**Code Example (Avoiding unnecessary object creation):**

"""ruby
# Anti-pattern: Creating a new array in each iteration
def anti_pattern(data)
  result = []
  data.each { |item| result << item.to_s }
  result
end

# Correct: Pre-allocate the array

def correct_pattern(data)
  result = Array.new(data.size)
  data.each_with_index { |item, index| result[index] = item.to_s }
  result
end
"""

### 2. String Manipulation

**Do This:** Use efficient string manipulation methods. Prefer "<<" or "concat" over "+" for appending.  Consider using frozen strings where appropriate to avoid duplication.

**Don't Do This:**  Use inefficient string concatenation methods, especially within loops.

**Why:** String operations can be performance-intensive.

**Code Example:**

"""ruby
# Efficient
string = "hello"
string << " world"

# Less efficient (creates a new string object each time)

string = "hello"
string = string + " world"

# Ruby 2.3+, use frozen string literals when possible

# frozen_string_literal: true

string = "hello".freeze #Avoids duplicating this string in memory
"""

### 3. Iteration

**Do This:** Choose the right iteration method based on the task. Use "each" for simple iteration, "map" for transforming elements, and "select" for filtering. For performance-critical loops, consider using "while" or "for" loops, or the C-accelerated versions when operating on "NArray"

**Don't Do This:** Use "each" when "map" or "select" is more appropriate, or vice-versa.

**Why:** Using correct iterators improves readability and offers performance gains. "while" and "for" loops can offer marginal performance increases in very hot loops.

**Code Example:**

"""ruby
# Efficient mapping
numbers = [1, 2, 3, 4, 5]
squares = numbers.map { |n| n * n }

# Efficient filtering

even_numbers = numbers.select { |n| n.even? }

# Efficient each

numbers.each { |n| puts n }
"""

### 4. Regular Expressions

**Do This:** Compile regular expressions and reuse them.  Use non-capturing groups "(?:...)" when capturing is not needed.  Be mindful of backtracking complexity.

**Don't Do This:** Create regular expressions every time they are needed or neglect complex regexes that can lead to excessive backtracking.

**Why:** Compiling regular expressions is expensive.  Backtracking can catastrophically degrade performance in complex regular expressions.

**Code Example:**

"""ruby
# Compile and reuse
EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze

def valid_email?(email)
  EMAIL_REGEX.match?(email)
end
"""

### 5. Memoization

**Do This:** Memoize the results of expensive function calls, especially pure functions. Use "||=" operator or dedicated memoization libraries.

**Don't Do This:** Memoize excessively or without a strategy to invalidate the cache when the underlying data changes.

**Why:** Avoid recomputing values already calculated.

**Code Example:**

"""ruby
def expensive_calculation(n)
  @cache ||= {}
  return @cache[n] if @cache.key?(n)

  puts "Calculating..."
  result = (1..n).sum # Simulate heavy computation
  @cache[n] = result
  result
end

puts expensive_calculation(10) # Calculates
puts expensive_calculation(10) # Retrieves from cache
"""

### 6. Lazy Evaluation

**Do This:** Use lazy evaluation (e.g., using "Enumerator::Lazy") for large collections and complex operations to avoid unnecessary computations.

**Don't Do This:** Use lazy evaluation indiscriminately; it adds overhead that can outweigh its benefits for small datasets.

**Why:** Only compute results when and if they are actually needed.

**Code Example:**

"""ruby
numbers = (1..Float::INFINITY).lazy.select { |n| n.even? }.map { |n| n * 2 }.first(10)
puts numbers # => [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
"""

### 7. Concurrency and Parallelism

**Do This:** Use threads, fibers, or processes for concurrent tasks. Employ parallel processing for CPU-bound tasks using gems like "concurrent-ruby" or "Parallel".  Consider using actor-based concurrency (e.g., celluloid).

**Don't Do This:** Introduce concurrency without proper synchronization, which can lead to race conditions and deadlocks. Ignore the limitations of MRI's Global Interpreter Lock (GIL).

**Why:** Leverage multi-core processors to perform tasks simultaneously.

**Code Example (using "concurrent-ruby"):**

"""ruby
require 'concurrent'

executor = Concurrent::FixedThreadPool.new(4) # 4 threads

futures = 10.times.map do |i|
  executor.post do
    puts "Processing task #{i} on thread: #{Thread.current.name}"
    sleep(rand(1..3)) # Simulate work
    "Result #{i}"
  end
end

results = futures.map(&:value) # Wait for all tasks to complete

puts "Results: #{results}"

executor.shutdown
executor.wait_for_termination
"""

### 8. Database Interactions

**Do This:** Use efficient database queries, indexes, and caching. Optimize N+1 queries.  Utilize connection pooling.

**Don't Do This:** Perform inefficient queries or ignore database-level optimizations.

**Why:** Database interactions often represent a major performance bottleneck.

**Code Example (Addressing N+1 Query with "includes" in Rails):**

"""ruby
# Inefficient
# @orders = Order.all
# @orders.each { |order| puts order.customer.name } # N+1 queries

# Efficient

@orders = Order.includes(:customer).all  # Eager loads customer data

@orders.each { |order| puts order.customer.name } # Single query
"""

### 9. Garbage Collection

**Do This:** Be aware of the impact of garbage collection. Trigger garbage collection manually when necessary (e.g., after large data processing). Control object allocation, prefer immutable objects or using object pools. Consider using garbage collection tuning options.

**Don't Do This:** Ignore garbage collection and let it become a source of performance problems due to excessive pauses.

**Why:** Excessive garbage collection pauses can significantly impact performance.

**Code Example:**

"""ruby
# Force garbage collection
GC.start

# Disable garbage collection

GC.disable

# Enable garbage collection

GC.enable
"""

However, manually triggering GC is generally best avoided unless you *know* there has been a lot of dead object creation and the GC hasn't kicked in.

### 10. Use Profilers

**Do This:** Use tools like RubyProf, stackprof, or flamegraph to identify hotspots in your code.

**Don't Do This:** Guess where performance bottlenecks lie; use profiling to locate them.

**Why:** Pinpoint the precise location of performance bottlenecks for focused optimization.

**Code Example (using RubyProf):**

"""ruby
require 'ruby-prof'

RubyProf.start

# Your code here

def my_slow_method
  100000.times { Math.sqrt(rand) }
end

my_slow_method

result = RubyProf.stop

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT) # Prints profiling results
"""

## III. Memory Management

### 1. Object Allocation

**Do This:** Minimize unnecessary object allocations, especially within loops or frequently called methods. Use object pooling or reuse existing objects when possible.

**Don't Do This:** Create many short-lived objects. These will be collected frequently & cause overhead on the garbage collector.

**Why:** Allocating objects is time-consuming. Minimizing it contributes directly to performance improvements.

**Code example:**

"""ruby
# Inefficient

def generate_strings(n)
  n.times.map { |i| "String #{i}" } # Each iteration creates a string
end

# Efficient

def generate_strings_efficient(n)
  base_string = "String ".dup   # Create one string
  n.times.map { |i| base_string.dup << i.to_s  } #  Copy and append the index number
end
"""

### 2. Immutable Objects

**Do This**: Use immutable objects whenever applicable. Since they can't be modified, they can be safely shared and cached without concern for unintended modifications.

**Don't Do This**: Avoid using mutable objects when you need to share state or data as they need to be duplicated to prevent issues.

**Why**: Immutable objects simplify reasoning about program state and allow optimizations such as sharing or reusing them. Consider using libraries like "hamster" for immutable data structures.

### 3. Weak References

**Do This**: Use Weak References if memory is low and some objects are not always necessary, but cached 'just in case'.

**Don't Do This**: Do it without the WeakRef support.

**Why**: Weak References are garbage collected if memory is needed by ruby and it won't complain about it.

Code Example:

"""ruby
require 'weakref'

obj = Object.new
weak_ref = WeakRef.new(obj)

puts weak_ref.weakref_alive?  # => true

obj = nil    # Remove reference to the object

GC.start     # Force garbage collection

puts weak_ref.weakref_alive?  # => false
"""

## IV. Specific Concerns: Rails Applications

### 1. Asset Pipeline

**Do This:** Precompile assets for production, use a CDN for static assets, and minimize asset size (e.g., using minification and compression).

**Don't Do This:** Serve uncompiled assets in production, or include large and unoptimized assets.

**Why:** Optimize the delivery of assets significantly improves page load times.

### 2. Query Optimization

**Do This:** Optimize database queries using indexes, eager loading ("includes"), and avoiding N+1 queries. Utilize database-specific features (e.g., PostgreSQL's JSONB indexes).

**Don't Do This:** Ignore slow queries or rely on inefficient database access patterns.

### 3. Caching

**Do This:** Implement caching strategies at various levels (e.g., fragment caching, page caching, low-level caching with "Rails.cache"). Use a cache store like Redis or Memcached.

**Don't Do This:** Cache inappropriately (e.g., caching personal data), or use overly aggressive or non-expiring caches.

### 4. Background Jobs

**Do This:** Offload long-running tasks to background jobs (e.g., using Sidekiq, Resque, or Delayed Job) to improve web response times.

**Don't Do This:** Perform complex and time-consuming operations within request-response cycles.

### 5. Middleware

**Do This:**  Carefully select and configure middleware components. Removing unnecessary middleware can reduce request processing overhead.

**Don't Do This:**  Add a lot of middlewares without actually seeing the benefits, as they can impact the performance negatively.

**Conclusion**

These performance optimization standards serve as a comprehensive guide for Ruby developers. By adhering to these guidelines, developers can create efficient, responsive, and scalable Ruby applications. Remember that continuous profiling, benchmarking, and monitoring are essential for identifying and addressing performance bottlenecks. Regularly revisiting and updating these standards will ensure they remain relevant with evolving Ruby versions and best practices.
