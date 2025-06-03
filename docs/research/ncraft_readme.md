# NCRAFT - nCino Code Review Automation Framework Tool

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/your-org/ncraft)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D2.7-red.svg)](https://www.ruby-lang.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

NCRAFT is an AI-powered automation framework that streamlines the software development workflow by integrating Jira ticket management, Git operations, and intelligent pull request generation. Built specifically for engineering teams using Jira and Git workflows, NCRAFT reduces manual overhead and improves code review quality through intelligent automation.

## Overview

### Core Capabilities
- **Automated Branch Creation**: Generate properly named Git branches from Jira tickets
- **AI-Enhanced PR Drafts**: Create comprehensive pull request descriptions using Claude AI
- **Intelligent Code Analysis**: Analyze code changes to suggest testing strategies and identify potential issues
- **Smart Reviewer Assignment**: Automatically assign reviewers based on code ownership and domain expertise
- **Jira Integration**: Full CRUD operations for Jira issues with MCP Atlassian server support
- **Team Analytics**: Track adoption metrics and time savings across engineering teams

### Key Benefits
- **Time Savings**: Reduces PR creation time from 20+ minutes to under 2 minutes
- **Consistency**: Ensures standardized PR descriptions and branch naming conventions
- **Quality**: AI-powered analysis improves review quality and catches potential issues early
- **Visibility**: Integrates with team communication tools for enhanced collaboration

## Installation

### Prerequisites
```bash
# Required Ruby version
ruby >= 2.7.0

# Required gems
gem install thor json colorize anthropic faraday

# Optional: MCP integration (recommended)
gem install ruby-mcp-client
```

### Setup
```bash
# Clone or download the ncraft.rb script
chmod +x ncraft.rb

# Optional: Add to PATH for global access
sudo ln -s /path/to/ncraft.rb /usr/local/bin/ncraft

# Initial configuration
./ncraft.rb configure
```

## Configuration

### Initial Setup
Run the configuration wizard to set up your environment:

```bash
ncraft configure
```

The configuration wizard will prompt for:
- Jira base URL and credentials
- AI service API keys (optional)
- Default Git branch preferences
- Team notification settings

### Configuration File Structure
Configuration is stored in `~/.ncraft/config.json`:

```json
{
  "jira_base_url": "https://ncinodev.atlassian.net",
  "jira_email": "your.email@company.com",
  "jira_token": "your-api-token",
  "jira_username": "your.email@company.com",
  "default_branch": "main",
  "enable_ai": true,
  "enable_mcp": true,
  "mcp_server_type": "sse",
  "mcp_server_url": "http://localhost:8080/mcp",
  "mcp_timeout": 30,
  "mcp_retry_attempts": 3,
  "anthropic_api_key": "your-anthropic-key",
  "enable_notifications": false,
  "enable_analytics": true,
  "max_reviewers": 3,
  "auto_assign_reviewers": true
}
```

### Team Configuration
Set up shared team defaults:

```bash
ncraft configure --team
```

Team configuration enables:
- Shared domain expertise mapping
- Standardized reviewer assignment rules
- Common notification channels
- Team-specific default values

## Basic Usage

### Creating PR Drafts from Jira Tickets

```bash
# Basic PR creation
ncraft create -t OMNI-1234 -d "implement-caching-layer"

# With custom base branch
ncraft create -t OMNI-1234 -d "hotfix-authentication" -b hotfix

# Disable AI analysis for speed
ncraft create -t OMNI-1234 -d "simple-fix" --no-ai
```

### Creating Jira Issues

```bash
# Basic issue creation
ncraft create-issue -p OMNI -s "Fix authentication bug" -T Bug -P High

# Advanced issue with custom fields
ncraft create-issue \
  -p OMNI \
  -s "Refactor event-driven architecture" \
  -d "Simplify UserLoanApp callbacks and event triggers" \
  -T Story \
  -P Medium \
  -a "developer@company.com" \
  -c "Authentication Component" \
  -sp 5 \
  -af '{"customfield_13048": {"id": "22933", "name": "Commercial Onboarding"}}'
```

### Searching Issues

```bash
# Search with JQL
ncraft search-issues -j "project = OMNI AND assignee = currentUser()"

# Export to CSV
ncraft search-issues -j "created >= -7d" -o csv > recent_issues.csv

# JSON format for further processing
ncraft search-issues -j "status = 'In Progress'" -o json
```

## Command Reference

### Core Commands

#### `create`
Generate branch and PR draft from Jira ticket.

**Options:**
- `-t, --ticket`: Jira ticket ID (required)
- `-d, --description`: Branch description (required)
- `-b, --base`: Base branch (optional, defaults to configured branch)
- `--no-ai`: Disable AI-powered analysis
- `--draft`: Create as draft PR

**Example:**
```bash
ncraft create -t PROJ-123 -d "implement-new-feature" -b develop
```

#### `create-issue`
Create new Jira issue with comprehensive field support.

**Options:**
- `-p, --project`: Project key (required)
- `-s, --summary`: Issue summary (required)
- `-d, --description`: Issue description
- `-T, --type`: Issue type (default: Story)
- `-P, --priority`: Priority (default: Medium)
- `-a, --assignee`: Assignee email or account ID
- `-c, --component`: Component name
- `-e, --epic`: Epic link (issue key)
- `-sp, --story_points`: Story points estimate
- `-af, --additional_fields`: Additional fields as JSON

**Example:**
```bash
ncraft create-issue -p OMNI -s "New feature" -T Story -P High -sp 8
```

#### `search-issues`
Search Jira issues using JQL with multiple output formats.

**Options:**
- `-j, --jql`: JQL query string (required)
- `-m, --max_results`: Maximum results (default: 10)
- `-o, --output`: Output format (table, json, csv)

**Example:**
```bash
ncraft search-issues -j "assignee = currentUser() AND status != Done" -m 20
```

### Utility Commands

#### `configure`
Interactive configuration setup.

**Options:**
- `--team`: Configure team-wide settings

#### `status`
Display configuration status and usage statistics.

#### `doctor`
Diagnose setup issues and validate configuration.

## AI-Powered Features

### Intelligent Code Analysis
NCRAFT uses Claude AI to analyze code changes and generate:

- **Contextual Summaries**: Understanding of what the changes accomplish
- **Technical Impact Assessment**: Performance, security, and architectural considerations
- **Testing Strategies**: Specific test scenarios based on actual code changes
- **Breaking Change Detection**: Identification of API or schema changes
- **Review Focus Areas**: Guidance for code reviewers

### Smart Reviewer Assignment
Automatic reviewer suggestion based on:

- **Code Ownership**: CODEOWNERS file integration
- **Domain Expertise**: Component and ticket type matching
- **Load Balancing**: Distribute review workload evenly
- **Historical Patterns**: AI analysis of past review effectiveness

### Example AI Analysis Output
```markdown
## AI Code Analysis

**Performance Impact:** Low - Changes primarily affect configuration layer

**Review Focus Areas:**
- Validate new caching configuration parameters
- Ensure backward compatibility with existing cache keys
- Review error handling for cache failures

**Testing Strategy:**
- [ ] Unit tests for new cache configuration methods
- [ ] Integration tests for cache hit/miss scenarios
- [ ] Performance tests comparing before/after metrics
```

## MCP Atlassian Integration

### Overview
NCRAFT integrates with the Model Context Protocol (MCP) Atlassian server for enhanced Jira operations with automatic fallback to REST API. The MCP integration provides superior performance, better error handling, and advanced features not available through standard REST API calls.

### Installation and Setup

#### Install MCP Client Gem
```bash
gem install ruby-mcp-client
```

#### MCP Server Types

**Server-Sent Events (SSE) - Recommended**
```json
{
  "enable_mcp": true,
  "mcp_server_type": "sse",
  "mcp_server_url": "http://localhost:8080/mcp",
  "mcp_timeout": 30,
  "mcp_retry_attempts": 3
}
```

**STDIO (Local Process)**
```json
{
  "enable_mcp": true,
  "mcp_server_type": "stdio",
  "mcp_server_command": "ruby",
  "mcp_server_args": ["./jira_mcp_server.rb"],
  "mcp_timeout": 30
}
```

### MCP-Specific Commands

#### Check MCP Status
```bash
# View MCP connection status and available tools
ncraft mcp-status
```

Example output:
```
🔗 MCP Connection Status        
──────────────────────────────────
✅ ruby-mcp-client gem: Available
✅ MCP integration: Enabled
✅ MCP server connection: Healthy
   Available tools: 8

⚙️ MCP Configuration
──────────────────────────────────
Server Type: sse
Server URL: http://localhost:8080/mcp
Timeout: 30s
Retry Attempts: 3

🔧 Available MCP Tools
──────────────────────────────────
• jira_get_issue: Fetch detailed issue information
• jira_create_issue: Create new Jira issues with custom fields
• jira_search_issues: Search issues using JQL
• jira_transition_issue: Change issue status
• jira_add_comment: Add comments to issues
```

### Supported MCP Operations
- **Issue Retrieval**: Enhanced field fetching with custom field support
- **Issue Creation**: Advanced issue creation with validation
- **Issue Search**: Optimized JQL-based querying with result caching
- **Issue Transitions**: Status changes with workflow validation
- **Comment Management**: Rich text comment support
- **Bulk Operations**: Batch processing for multiple issues

### Configuration Options

#### Connection Settings
```json
{
  "mcp_connection_timeout": 10,
  "mcp_read_timeout": 30,
  "mcp_retry_attempts": 3,
  "mcp_timeout": 30
}
```

#### Authentication
MCP servers automatically inherit authentication from NCRAFT configuration:
- `jira_token`: Used as Bearer token for SSE connections
- Environment variables passed to STDIO processes
- Automatic credential management and refresh

### Error Handling and Fallback

The MCP integration includes robust error handling:

- **Automatic Fallback**: Seamlessly switches to REST API if MCP fails
- **Retry Logic**: Configurable retry attempts with exponential backoff
- **Connection Pooling**: Efficient connection reuse and management
- **Health Monitoring**: Continuous health checks with automatic recovery

#### Fallback Scenarios
1. MCP server unavailable → REST API
2. Tool not available via MCP → REST API equivalent
3. Authentication failure → REST API with direct credentials
4. Timeout or network issues → Retry then fallback

### Troubleshooting MCP Issues

#### Common Problems

**Connection Refused**
```bash
# Check server status
ncraft mcp-status

# Test with curl (for SSE servers)
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8080/mcp/health
```

**Tools Not Available**
```bash
# List available tools
ncraft mcp-status

# Check server logs for tool registration issues
```

**Authentication Failures**
```bash
# Verify credentials
ncraft doctor

# Check server-side authentication configuration
```

#### Debug Mode
Enable detailed MCP logging:
```json
{
  "debug_mode": true,
  "mcp_debug": true
}
```

Or set environment variable:
```bash
DEBUG=1 ncraft create -t PROJ-123 -d "test"
```

### Performance Benefits

MCP integration provides significant performance improvements:

- **Reduced Latency**: Direct protocol communication vs HTTP overhead
- **Batch Operations**: Multiple operations in single request
- **Connection Reuse**: Persistent connections reduce setup time
- **Result Caching**: Server-side caching reduces redundant API calls
- **Streaming**: Large result sets streamed efficiently

### Security Considerations

- **Credential Management**: Tokens stored securely, never logged
- **Connection Security**: TLS encryption for remote connections
- **Access Control**: Server-side permission validation
- **Audit Logging**: Comprehensive operation logging for compliance

## Team Integration

### Code Ownership Integration
NCRAFT automatically assigns reviewers based on code ownership patterns:

```bash
# .github/CODEOWNERS example
*.rb                    @backend-team
/frontend/              @frontend-team
/config/                @devops-team @senior-engineers
/spec/                  @qa-team @backend-team
```

### Notification Systems
Integrate with team communication tools:

#### Slack Integration
```json
{
  "enable_notifications": true,
  "slack_webhook": "https://hooks.slack.com/services/YOUR/WEBHOOK/URL",
  "notification_channels": ["#engineering", "#code-reviews"]
}
```

#### Microsoft Teams Integration
```json
{
  "teams_webhook": "https://your-org.webhook.office.com/webhookb2/...",
  "teams_channels": ["Engineering", "Code Reviews"]
}
```

## Analytics and Metrics

### Usage Tracking
NCRAFT automatically tracks usage metrics to demonstrate ROI:

- **Time Savings**: Calculated based on estimated manual process time
- **Adoption Rate**: Percentage of PRs created with NCRAFT
- **Success Rate**: Ratio of successful to failed operations
- **Team Statistics**: Cross-team adoption and contribution metrics

### Viewing Analytics
```bash
# Individual statistics
ncraft status

# Team-wide analytics (requires team configuration)
ncraft status --team
```

### Sample Analytics Output
```
📊 Configuration Status
──────────────────────────────────
✅ Jira connection
✅ Git repository
✅ AI service configuration
✅ File permissions

📈 Usage Statistics
──────────────────────────────────
PRs created this week: 12
Total time saved: 6.2 hours
Average completion time: 1.8 seconds
Success rate: 95.8%

👥 Team Statistics
──────────────────────────────────
Team adoption rate: 78%
Most active contributors: alice.smith, bob.johnson
```

## Advanced Configuration

### Domain Expertise Mapping
Configure team expertise for intelligent reviewer assignment:

```json
{
  "domain_experts": {
    "Story": ["senior.dev@company.com", "tech.lead@company.com"],
    "Bug": ["qa.engineer@company.com", "senior.dev@company.com"],
    "Authentication": ["security.expert@company.com"],
    "Database": ["dba@company.com", "backend.lead@company.com"]
  }
}
```

### Custom Field Mapping
Map common custom fields for easier issue creation:

```json
{
  "custom_field_mappings": {
    "epic_link": "customfield_10014",
    "story_points": "customfield_10016",
    "component_field": "customfield_13048",
    "sprint_field": "customfield_10020"
  }
}
```

### PR Template Customization
NCRAFT looks for PR templates in these locations:
1. `.github/PULL_REQUEST_TEMPLATE.md`
2. `PULL_REQUEST_TEMPLATE.md`
3. Custom paths defined in configuration

### AI Prompt Customization
Advanced users can customize AI analysis prompts:

```json
{
  "ai_prompts": {
    "code_analysis": "Custom prompt for code analysis...",
    "test_strategy": "Custom prompt for test planning...",
    "security_review": "Custom prompt for security analysis..."
  }
}
```

## Troubleshooting

### Common Issues

#### Jira Connection Problems
```bash
# Verify configuration
ncraft doctor

# Test connection manually
curl -u "email:token" "https://your-jira.atlassian.net/rest/api/3/myself"
```

**Solutions:**
- Verify API token is current and has correct permissions
- Check Jira base URL format (include https://)
- Ensure user has required project permissions

#### Git Repository Issues
```bash
# Verify git status
git status
git remote -v
```

**Solutions:**
- Ensure you're in a git repository
- Verify base branch exists locally or remotely
- Check git remote configuration

#### AI Service Failures
```bash
# Check AI configuration
ncraft status
```

**Solutions:**
- Verify Anthropic API key is valid
- Check network connectivity
- Use `--no-ai` flag as temporary workaround

#### MCP Connection Issues
```bash
# Disable MCP temporarily
ncraft create -t TICKET-123 -d "description" --no-mcp
```

**Solutions:**
- Verify MCP server is running
- Check MCP server URL in configuration
- Review MCP server logs for errors

### Debug Mode
Enable detailed logging for troubleshooting:

```json
{
  "debug_mode": true,
  "log_level": "DEBUG"
}
```

### Log Files
NCRAFT logs are written to:
- Configuration issues: Console output
- Runtime errors: `~/.ncraft/logs/ncraft.log`
- Analytics data: `~/.ncraft/analytics.json`

## Performance Considerations

### Optimization Strategies
- **Caching**: Jira ticket data is cached to reduce API calls
- **Batch Operations**: Multiple operations are batched when possible
- **Lazy Loading**: AI analysis only runs when requested
- **Connection Pooling**: HTTP connections are reused for efficiency

### Resource Usage
- **Memory**: Typical usage < 50MB
- **Network**: Minimal bandwidth usage with intelligent caching
- **Disk Space**: Configuration and cache files < 10MB

### Scalability Notes
- Designed for teams of 5-50 engineers
- Jira API rate limits respected with built-in throttling
- Can handle 100+ PR creations per day per team

## Security Considerations

### Credential Storage
- API tokens stored in user home directory with restricted permissions (600)
- No credentials stored in plain text logs
- Team configuration excludes sensitive individual settings

### Network Security
- All API communications use HTTPS
- Supports corporate proxy configurations
- No external data transmission beyond configured services

### Access Control
- Respects existing Jira project permissions
- Git operations limited to current repository context
- No elevation of user privileges

## Contributing

### Development Setup
```bash
# Clone repository
git clone https://github.com/your-org/ncraft.git
cd ncraft

# Install development dependencies
bundle install

# Run tests
rake test

# Run linter
rubocop
```

### Code Organization
The NCRAFT codebase is organized into focused modules:

- **Configuration**: Settings management and validation
- **JiraIntegration**: All Jira API operations
- **GitOperations**: Git repository management
- **PRGeneration**: AI-powered PR draft creation
- **ReviewerAssignment**: Intelligent reviewer suggestion
- **TeamIntegration**: Notifications and team features
- **Analytics**: Usage tracking and metrics

### Adding New Features

#### Creating New Commands
```ruby
desc "new-command", "Description of new command"
option :param, aliases: "-p", desc: "Parameter description"
def new_command
  # Implementation
end
```

#### Extending AI Analysis
```ruby
module PRGeneration
  def custom_analysis(diff, ticket_info)
    # Custom AI analysis logic
  end
end
```

#### Adding New Integrations
```ruby
module NewIntegration
  extend self
  
  def integrate_with_service(config)
    # Integration implementation
  end
end
```

### Testing Guidelines
- Unit tests for all modules
- Integration tests for external API calls
- Mock external dependencies in tests
- Test both success and failure scenarios

### Submission Process
1. Fork the repository
2. Create feature branch from `main`
3. Implement changes with tests
4. Update documentation
5. Submit pull request with detailed description

## Roadmap

### Planned Features
- **GitHub/GitLab Integration**: Direct PR creation
- **Enhanced AI Models**: Support for additional AI providers
- **Web Dashboard**: Team analytics and configuration UI
- **Plugin Architecture**: Extensible integration system
- **Mobile Notifications**: Slack/Teams mobile integration

### Version History
- **2.0.0**: MCP integration, AI enhancements, team features
- **1.0.0**: Initial release with basic PR generation

## Support

### Documentation
- [API Reference](docs/api-reference.md)
- [Configuration Guide](docs/configuration.md)
- [Troubleshooting Guide](docs/troubleshooting.md)

### Community
- [GitHub Issues](https://github.com/your-org/ncraft/issues)
- [Discussions](https://github.com/your-org/ncraft/discussions)
- Internal Slack: `#ncraft-support`

### Professional Support
For enterprise support and custom integrations:
- Email: ncraft-support@yourcompany.com
- Internal wiki: [NCRAFT Documentation](https://wiki.company.com/ncraft)

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- Claude AI by Anthropic for intelligent code analysis
- Thor gem for elegant command-line interface
- Ruby community for excellent gem ecosystem
- nCino engineering team for feedback and contributions

---

*NCRAFT - Transforming code review workflows through intelligent automation*