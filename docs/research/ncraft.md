
ncraft workflow -t TICKET-123 -d "description"

# Using with an existing ticket
ncraft workflow -t PROJECT-123 -d "add user authentication"

# Creating a new ticket in a specific project
ncraft workflow -t PROJECT-456 -d "implement search feature" -p PROJECT


## 🎯 Key Features Included:

### Core Functionality:

✅ Branch Creation & PR Generation - Automated from Jira tickets
✅ nCino Compliance Analysis - Comprehensive Salesforce platform checks
✅ Security Scanning - Detects vulnerabilities and hardcoded credentials
✅ Code Review Automation - Multi-language analysis
✅ Configuration Management - Easy setup and customization

### nCino-Specific Analysis:

🏢 Apex Standards - Bulkification, sharing models, governor limits, test coverage
🔄 Flow Compliance - Inactive packaging, access control, error handling
⚡ Vue/Lightning - SLDS compliance, accessibility, component sizing
🔧 LWC Analysis - Wire services, security, event handling
📊 Orchestration Patterns - Step/Service validation, state management

### Security Features:

🔒 Credential Detection - Finds hardcoded passwords, API keys, secrets
🛡️ Injection Prevention - SOQL injection, XSS vulnerabilities
🔐 Crypto Analysis - Weak algorithm detection
🚨 Access Control - Sharing model validation

### Advanced Capabilities:

📈 Analytics & Reporting - Usage tracking, compliance metrics
🔧 Auto-fixing - Automatic resolution of common violations
📋 Multiple Output Formats - Console, JSON, HTML, CSV
🎯 Targeted Scanning - File pattern matching, severity filtering

## 🚀 Usage Examples:

### Make the script executable
`chmod +x ~/Desktop/ncraft.rb`

### Configure NCRAFT
`./ncraft.rb configure`

### Create PR from Jira ticket with full analysis
`./ncraft.rb create -t OMNI-123 -d "implement-new-feature"`

### Run comprehensive nCino compliance analysis
`./ncraft.rb ncino-analyze /path/to/salesforce/code`

### Perform security scan
`./ncraft.rb security-scan /path/to/code --export security_report.json`




NCRAFT Service Classes Implementation Complete
I've implemented all the required service classes for the NCRAFT (nCino Code Review Automation Framework Tool) with a modern, modular architecture. The tool is now organized following best practices for maintainability, testability, and extensibility.

Implemented Components
Configuration System
Secure credential management with environment variable support
JSON-based configuration with sensible defaults
User and team configuration support
Service Classes
Analytics - Anonymous usage tracking for tool improvement
GitOperations - Git repository interactions and branch management
JiraIntegration - JIRA API integration for ticket management
PRGeneration - Pull request draft generation with AI enhancement
EnvironmentValidator - Environment and dependency validation
Code Reviewers
Base reviewer with common checks for all files
Language-specific reviewers:
RubyReviewer - Ruby, Rails specific best practices
JavaScriptReviewer - JavaScript, Vue.js analysis
GenericReviewer - GraphQL, CSS, SQL, YAML, JSON analysis
CLI Interface
Thor-based command-line interface with descriptive help
Comprehensive subcommands (create, create_issue, search_issues, etc.)
Colorized output for better readability
Architecture Highlights
Separation of Concerns: Each class has a single responsibility
Dependency Injection: Services accept dependencies for better testability
Strategy Pattern: Different file reviewers based on file type
Configuration Management: Centralized configuration system
Next Steps
Testing: Add unit and integration tests
Documentation: Create comprehensive user and developer documentation
Packaging: Create a gem for easy installation



## 🔧 Next Steps:

### Install Dependencies:
`bashgem install thor json colorize faraday`

### Run Configuration:
`bash./ncraft.rb configure`

### Test the Tool:
`bash./ncraft.rb status`

The script is now ready to use and includes all the advanced nCino compliance checking, security scanning, and automation features we designed. It will help streamline your development workflow while ensuring adherence to nCino's Salesforce platform standards!RetryClaude can make mistakes. Please double-check responses.
