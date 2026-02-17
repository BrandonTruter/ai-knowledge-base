# Core Architecture Standards for SOLID

> From [CodingRules.ai](https://codingrules.ai/rules/core-architecture-standards-for-solid)

**Tags:** SOLID

---

# Core Architecture Standards for SOLID

This document outlines the core architectural standards for building maintainable, scalable, and robust applications using the SOLID principles. These standards focus on how SOLID principles influence overall project structure, architectural patterns, and organization to achieve long-term software quality.

## 1. Architectural Patterns and SOLID Principles

The choice of architectural pattern significantly impacts the application of SOLID principles. This section describes how different patterns align with SOLID and provides guidance on selecting appropriate patterns. Our focus will be on layers and hexagonal architecture as these tend to serve as good architectural patterns to help build high quality software.

### 1.1 Layered Architecture

Layered architecture divides the application into distinct layers, each with a specific responsibility. This approach inherently supports the Single Responsibility Principle (SRP) and promotes separation of concerns.

**Standards:**

*   **Do This:** Design layers to isolate functionality.  A typical tiered architecture may involve Presentation, Application, Domain and Infrastructure tiers.
*   **Don't Do This:** Allow layers to depend on each other arbitrarily. Enforce a strict layering where each layer only depends on the layer directly below it. Avoid skipping layers.
*   **Why:** Enforcing strict layering reduces coupling, making changes within one layer less likely to impact other layers.

**Code Example:**

"""csharp
// Domain Layer (Entities)
public class Customer
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }
}

// Application Layer (Services) - depends on Domain
public interface ICustomerService
{
    Customer GetCustomer(Guid id);
    void CreateCustomer(Customer customer);
}

public class CustomerService : ICustomerService
{
    private readonly ICustomerRepository _customerRepository;

    public CustomerService(ICustomerRepository customerRepository)
    {
        _customerRepository = customerRepository;
    }

    public Customer GetCustomer(Guid id)
    {
        return _customerRepository.GetById(id);
    }

    public void CreateCustomer(Customer customer)
    {
        //Business logic
        _customerRepository.Add(customer);
    }
}

// Infrastructure Layer (Repositories) - depends on Domain
public interface ICustomerRepository
{
    Customer GetById(Guid id);  //get customer by ID
    void Add(Customer customer);  //add customer to the repository
}

public class CustomerRepository : ICustomerRepository
{
    private readonly DbContext _context; // Assuming Entity Framework Core

    public CustomerRepository(DbContext context)
    {
        _context = context;
    }

    public Customer GetById(Guid id)
    {
        return _context.Set<Customer>().Find(id);
    }

    public void Add(Customer customer)
    {
        _context.Set<Customer>().Add(customer);
        _context.SaveChanges();
    }
}

// Presentation Layer (Controllers) - depends on Application
public class CustomerController : ControllerBase
{
    private readonly ICustomerService _customerService;

    public CustomerController(ICustomerService customerService)
    {
        _customerService = customerService;
    }

    [HttpGet("{id}")]
    public IActionResult Get(Guid id)
    {
        var customer = _customerService.GetCustomer(id);
        if (customer == null)
        {
            return NotFound();
        }
        return Ok(customer);
    }

     [HttpPost]
    public IActionResult Create([FromBody] Customer customer)
    {
         _customerService.CreateCustomer(customer);
         return CreatedAtAction(nameof(Get), new { id = customer.Id }, customer);

    }
}
"""

**Anti-Pattern:**

*   **God Class:** A single class that performs excessive operations across multiple layers.  This violates SRP and creates tight coupling.

### 1.2 Hexagonal Architecture (Ports and Adapters)

Hexagonal architecture, also known as ports and adapters, is great for the Dependency Inversion Principle (DIP). It emphasizes isolating the core business logic from external dependencies like databases, UI frameworks, and external services.

**Standards:**

*   **Do This:** Define clear interfaces (ports) for interacting with external elements. Implement specific adapters for each dependency.
*   **Don't Do This:** Directly embed external frameworks or libraries within the core business logic.
*   **Why:** This approach makes the core application independent of external technologies, allowing for easier testing and future technology changes.

**Code Example:**

"""csharp
// Core (Domain) - Independent from External dependencies
// Port (Interface)
public interface IEmailService
{
    void SendEmail(string to, string subject, string body);
}

// Core Business logic (Service)
public class OrderService
{
    private readonly IEmailService _emailService;

    public OrderService(IEmailService emailService)
    {
        _emailService = emailService;
    }

    public void PlaceOrder(Order order)
    {
        // Order placement business logic

        // Send confirmation email - using the port
        _emailService.SendEmail(order.CustomerEmail, "Order Confirmation", "Your order has been placed.");
    }
}

// Infrastructure (Adapter) - Depends on the infrastructure concerns
// Adapter for EmailService (using SMTP)
public class SmtpEmailService : IEmailService
{
    public void SendEmail(string to, string subject, string body)
    {
        // SMTP implementation to actually send email
        Console.WriteLine($"Sending email to {to} with subject {subject}"); // Example
    }
}

// Usage
public class Program
{
    public static void Main(string[] args)
    {
         // Composition Root.  Dependency Injection should ideally handle this.
        var smtpEmailService = new SmtpEmailService();
        var orderService = new OrderService(smtpEmailService);

        var order = new Order { CustomerEmail = "test@example.com" };
        orderService.PlaceOrder(order);
    }
}
"""

**Anti-Pattern:**

*   **Direct Dependency:** Injecting a concrete implementation directly into a class instead of an interface. For example, directly using "SmtpEmailService" instead of "IEmailService" in the "OrderService" class.
*   **Lack of Abstraction:**  Not abstracting away the Infrastructure tier from the Domain tier.  This makes testing code and loose coupling very difficult to achieve.

## 2. Project Structure and Organization

A well-organized project structure is essential for maintainability and scalability. The following standards guide project layout and organization of code files.

### 2.1 Directory Structure

*   **Do This:** Organize the project by feature or bounded context and then layer.
*   **Don't Do This:** Organize by technology (e.g., all controllers in one folder, all models in another, all services in yet another). This can lead to feature fragmentation and high coupling.
*   **Why:** Feature-based organization improves code locality and makes it easier to understand and modify specific application features.

**Example Directory Structure:**

"""
MyProject/
├── src/
│   ├── Customers/                # Feature: Customer Management
│   │   ├── Domain/             # Domain Layer
│   │   │   ├── Customer.cs     # Customer Entity
│   │   │   ├── ICustomerRepository.cs # Repository Interface
│   │   ├── Application/          # Application Layer
│   │   │   ├── CustomerService.cs  # Customer Service
│   │   │   ├── ICustomerService.cs # Service interface
│   │   ├── Infrastructure/       # Infrastructure Layer
│   │   │   ├── CustomerRepository.cs # Repository Implementation
│   │   ├── Presentation/       # Presentation (API/UI) Layer - e.g. API
│   │   │   ├── CustomersController.cs # Controller
│   ├── Orders/                   # Feature: Order Management
│   │   ├── Domain/
│   │   ├── Application/
│   │   ├── Infrastructure/
│   │   ├── Presentation/
│   ├── Shared/                  # Common functionalities
│   │   ├── Models/
│   │   ├── Interfaces/
"""

### 2.2 Code File Organization

*   **Do This:** Keep classes small and focused on a single responsibility. Separate interfaces from their implementations.
*   **Don't Do This:** Place multiple unrelated classes in a single file. Create large "utility" classes with many unrelated methods.
*   **Why:** Small, focused classes improve readability, maintainability, and testability.

**Code Example:**

"""csharp
// ICustomerService.cs (Interface)
public interface ICustomerService
{
    Customer GetCustomer(Guid id);
    void CreateCustomer(Customer customer);
}

// CustomerService.cs (Implementation)
public class CustomerService : ICustomerService
{
    private readonly ICustomerRepository _customerRepository;

    public CustomerService(ICustomerRepository customerRepository)
    {
        _customerRepository = customerRepository;
    }

    public Customer GetCustomer(Guid id)
    {
        return _customerRepository.GetById(id);
    }

    public void CreateCustomer(Customer customer)
    {
        _customerRepository.Add(customer);
    }
}
"""

## 3. Dependency Management and Inversion of Control (IoC)

Proper dependency management is crucial for applying the Dependency Inversion Principle (DIP).

### 3.1 Dependency Injection (DI)

Dependency Injection (DI)is a software design pattern in which one or more dependencies (or services) are injected into a dependent object (or client) instead of the dependent object creating or obtaining the dependencies itself.

*   **Do This:** Use a DI container to manage dependencies. Constructor injection should be preferred.  Property and method injection should only be used in specific cases.
*   **Don't Do This:** Hardcode dependencies within classes using "new". Use Service Locator pattern as a primary means of dependency management.
*   **Why:** DI provides loose coupling and allows for easy testing and configuration of dependencies.

**Code Example (using .NET Core DI Container):**

"""csharp
// Startup.cs (or Program.cs in newer versions)
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        // Register Dependencies
        services.AddScoped<ICustomerService, CustomerService>();
        services.AddScoped<ICustomerRepository, CustomerRepository>();
        services.AddDbContext<MyDbContext>(options =>
            options.UseSqlServer(Configuration.GetConnectionString("DefaultConnection")));

        services.AddControllers();
    }

    ...
}

// CustomerController.cs (using injected dependencies)
public class CustomerController : ControllerBase
{
    private readonly ICustomerService _customerService;

    public CustomerController(ICustomerService customerService)
    {
        _customerService = customerService;
    }

    [HttpGet("{id}")]
    public IActionResult Get(Guid id)
    {
        var customer = _customerService.GetCustomer(id);  // Use injected dependency
        if (customer == null)
        {
            return NotFound();
        }

        return Ok(customer);
    }
}

"""

### 3.2 Composition Root

*   **Do This:** Define a clear composition root in your application where all dependencies are resolved, typically in your "Startup.cs" (or "Program.cs" for .NET 6 and later).
*   **Don't Do This:** Scatter dependency resolution logic throughout the application.
*   **Why:** The composition root centralizes dependency management, making it easier to understand and update.

## 4. Abstraction and Interfaces

Effective use of interfaces is the foundation for the Open/Closed Principle (OCP) and the Interface Segregation Principle (ISP).

### 4.1 Interface Design

*   **Do This:** Define interfaces that represent the "contract" between components. Ensure that interfaces are cohesive and focused.
*   **Don't Do This:** Create overly large or generic interfaces that violate ISP.
*   **Why:** Well-defined interfaces provide abstraction and allow you to substitute implementations without modifying client code.

**Code Example:**

"""csharp
// Good: Focused Interface
public interface IOrderProcessor
{
    void ProcessOrder(Order order);
}

// Bad: God Interface (violates ISP)
public interface IGenericService
{
    Customer GetCustomer(Guid id);
    void CreateCustomer(Customer customer);
    Order GetOrder(Guid id);
    void ProcessOrder(Order order);
    // ... many unrelated methods
}
"""

### 4.2 Abstract Classes vs. Interfaces

*   **Do This:** Prefer interfaces for defining contracts.  Use abstract classes only if you need to provide some default implementation.
*   **Don't Do This:** Overuse abstract classes, especially when an interface would suffice.
*   **Why:** Interfaces promote loose coupling and facilitate polymorphism.

## 5. Handling Cross-Cutting Concerns

Cross-cutting concerns (logging, authentication, authorization, caching, exception handling) should be handled in a way that doesn’t violate SOLID principles, especially SRP. This often involves aspects.

### 5.1 Decorator Pattern

*   **Do this:** Use the decorator pattern to add responsibilities to individual objects dynamically without affecting other objects.
*   **Don't Do This:** Modify the core class directly to add cross-cutting concerns. Put logging and authentication directly into your service operations.
*   **Why:** This keeps the core logic clean and focused on its primary responsibility.

**Code Example:**

"""csharp
// Interface
public interface IEmailService
{
    void SendEmail(string to, string subject, string body);
}

// Implementation
public class EmailService : IEmailService
{
    public void SendEmail(string to, string subject, string body)
    {
      Console.WriteLine($"Sending email to {to} with subject {subject}");
    }
}

// Decorator
public class LoggingEmailService : IEmailService
{
    private readonly IEmailService _emailService;
    private readonly ILogger<LoggingEmailService> _logger;

    public LoggingEmailService(IEmailService emailService, ILogger<LoggingEmailService> logger)
    {
        _emailService = emailService;
        _logger = logger;
    }

    public void SendEmail(string to, string subject, string body)
    {
        _logger.LogInformation($"Sending email to {to}...");
        _emailService.SendEmail(to, subject, body);
        _logger.LogInformation($"Email sent to {to}.");
    }
}

// Usage (Composition Root or DI Container)
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddScoped<IEmailService, EmailService>();
        services.AddScoped<IEmailService>(provider =>
        {
            var emailService = provider.GetService<EmailService>();
            var logger = provider.GetService<ILogger<LoggingEmailService>>();
            return new LoggingEmailService(emailService, logger);
        });
    }
}
"""

### 5.2 Middleware

*   **Do This:** Use middleware to handle concerns like authentication and exception handling in request processing pipelines.
*   **Don't Do This:** Embed authentication or exception handling logic directly within controllers or services. The request context should not bleed into the core domain logic.
*   **Why:** Middleware keeps cross-cutting concerns separate from the core application logic.

**Code Example (.NET Core):**

"""csharp
// Exception Handling Middleware
public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An unhandled exception occurred.");
            context.Response.StatusCode = 500;
            await context.Response.WriteAsync("An error occurred. Please try again later.");
        }
    }
}

// Extension method for easier usage in Startup.cs
public static class ExceptionHandlingMiddlewareExtensions
{
    public static IApplicationBuilder UseExceptionHandling(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<ExceptionHandlingMiddleware>();
    }
}

// Startup.cs
public class Startup
{
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        app.UseExceptionHandling(); // Register middleware
        app.UseRouting();
        app.UseEndpoints(endpoints =>
        {
            endpoints.MapControllers();
        });
    }
}
"""

## 6. Testing & SOLID

SOLID principles have a profound impact on the testability of code. Code that adheres to SOLID is inherently easier to test.

### 6.1 Unit Testing

*   **Do This:** Write unit tests for all classes, ensuring good coverage.  Mock or stub dependencies to isolate the class under test. Prefer arrange-act-assert (AAA) pattern.
*   **Don't Do This:** Write tests that directly depend on external resources (databases, APIs, etc.).
*   **Why:** Unit tests verify that each class behaves as expected in isolation, leading to more robust and maintainable software.

**Code Example (xUnit & Moq):**

"""csharp
// Unit Test
using Moq;
using Xunit;

public class CustomerServiceTests
{
    [Fact]
    public void GetCustomer_ExistingId_ReturnsCustomer()
    {
        // Arrange
        var mockRepository = new Mock<ICustomerRepository>();
        var expectedCustomer = new Customer { Id = Guid.NewGuid(), Name = "John Doe" };
        mockRepository.Setup(repo => repo.GetById(expectedCustomer.Id)).Returns(expectedCustomer);

        var customerService = new CustomerService(mockRepository.Object);

        // Act
        var actualCustomer = customerService.GetCustomer(expectedCustomer.Id);

        // Assert
        Assert.Equal(expectedCustomer.Name, actualCustomer.Name);
    }

    [Fact]
    public void CreateCustomer_ValidCustomer_CallsAddOnRepository()
    {
        // Arrange
        var mockRepository = new Mock<ICustomerRepository>();
        var customerService = new CustomerService(mockRepository.Object);
        var newCustomer = new Customer { Id = Guid.NewGuid(), Name = "Jane Doe" };

        // Act
        customerService.CreateCustomer(newCustomer);

        // Assert
        mockRepository.Verify(repo => repo.Add(newCustomer), Times.Once);
    }
}
"""

### 6.2 Integration Testing

*   **Do This:** Write integration tests to verify that different components of the application work together correctly.
*   **Don't Do This:** Skip integration tests, assuming unit tests are sufficient.
*   **Why:** Integration tests ensure that the application functions correctly as a whole.

## 7. Error Handling

Robust error handling that also avoids violating SOLID.

### 7.1 Exception Handling

*   **Do This:** Catch specific exceptions where appropriate and handle them gracefully. Log exceptions with sufficient context. Throw custom exceptions to provide more specific error information when necessary.
*   **Don't Do This:** Catch generic exceptions ("Exception") without re-throwing or logging. Ignore exceptions.
*   **Why:** Proper exception handling prevents application crashes and provides valuable diagnostic information.  Returning error codes within the domain without throwing exceptions is acceptable.

**Code Example:**

"""csharp
public class OrderService
{
    private readonly IOrderRepository _orderRepository;
    private readonly ILogger<OrderService> _logger;

    public OrderService(IOrderRepository orderRepository, ILogger<OrderService> logger)
    {
        _orderRepository = orderRepository;
        _logger = logger;
    }

    public void PlaceOrder(Order order)
    {
        try
        {
            _orderRepository.Add(order);
        }
        catch (DatabaseException ex)
        {
            _logger.LogError(ex, "Error placing order.");
            throw new OrderPlacementException("Failed to place order due to database error.", ex); // Custom exception
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error placing order.");
            throw; // Re-throw unexpected exceptions
        }
    }
}
"""

### 7.2 Fallback Mechanisms

*   **Do This:** Implement fallback mechanisms (circuit breakers, retry policies) to handle transient failures. Using Polly package from NuGet is advised.
*   **Don't Do This:** Let the application crash or hang indefinitely due to transient errors.
*   **Why:** Fallback mechanisms improve the resilience and availability of the application.

## 8. Documentation

Comprehensive documentation is essential for understanding and maintaining SOLID-based architecture.

### 8.1 Code Comments

*   **Do This:** Add clear, concise comments to explain complex logic. Use XML documentation comments to document public APIs.
*   **Don't Do This:** Over-comment obvious code. Let code comments become outdated.
*   **Why:** Well-maintained code comments help developers understand and maintain the code.

"""csharp
/// <summary>
/// Retrieves a customer by its unique identifier.
/// </summary>
/// <param name="id">The unique identifier of the customer.</param>
/// <returns>The customer object if found; otherwise, null.</returns>
public Customer GetCustomer(Guid id)
{
    return _customerRepository.GetById(id);
}
"""

### 8.2 Architectural Documentation

*   **Do This:** Create high-level architectural diagrams and documentation to explain the overall structure and design of the application.
*   **Don't Do This:** Rely solely on code comments to explain the architecture.
*   **Why:** Architectural documentation provides a clear overview of the system, making it easier for new developers to understand and contribute.

## 9. Evolution and Refactoring

SOLID principles provide guidance for evolving and refactoring the application over time.

### 9.1 Continuous Refactoring

*   **Do This:** Continuously refactor code to improve its structure, readability, and maintainability. Apply SOLID principles as a guide during refactoring.
*   **Don't Do This:** Let the codebase accumulate technical debt. Defer refactoring indefinitely.
*   **Why:** Continuous refactoring keeps the codebase healthy and adaptable to changing requirements.

### 9.2 Impact Analysis

*   **Do This:** Analyze the impact of changes before implementing them. Ensure that changes do not violate SOLID principles.
*   **Don't Do This:** Make large, sweeping changes without understanding their potential impact.
*   **Why:** Impact analysis helps prevent unintended consequences and maintain the integrity of the architecture.

By following these core architectural standards for SOLID principles, development teams can build applications that are maintainable, scalable, and robust. This will enable them to adapt quickly to changing requirements and deliver high-quality software.
