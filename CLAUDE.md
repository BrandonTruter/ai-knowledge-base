# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an AI Knowledge Base containing curated prompts, agent definitions, command libraries, and development workflows designed to enhance AI-powered development productivity. It serves as a comprehensive resource library for Claude Code interactions, supporting structured prompt engineering and specialized agent capabilities.

**Strategic Purpose:** Part of the broader ai-powered-workflows ecosystem, this knowledge base provides reusable AI interaction patterns, specialized agent definitions, and development workflow automations.

## High-Level Architecture

The repository follows a modular, domain-organized structure optimized for AI discovery and progressive disclosure:

### Core Architecture Patterns

**Agent-Based Organization**: Specialized agents are defined with specific capabilities and use cases:
- `agents/development/` - Software development specialists (sourcerer, reviewer, debugger)
- `agents/documents/` - Documentation and content processing agents
- `agents/frameworks/` - Language/framework-specific agents (Ruby, frontend, data science)
- `agents/tests/` - Testing and QA automation agents
- `agents/workflows/` - Complex multi-step workflow orchestrators

**Command Libraries**: Pre-built slash commands organized by AI platform:
- `commands/claude/` - Claude-specific commands and workflows
- `commands/cursor/` - Cursor IDE integration commands
- `commands/cody/` - Cody AI assistant commands
- `commands/rails/` - Rails-specific development commands
- `commands/roo/` - Specialized mode-based commands

**Skills Collection**: Agent Skills following the progressive disclosure pattern:
- `skills/collection/` - Packaged capabilities (code review, testing, documentation)
- Skills use SKILL.md format with YAML frontmatter for metadata
- Support bundled resources (scripts, templates, references)

**Rules and Standards**: Development standards and coding conventions:
- `rules/` - Platform-specific coding standards and best practices
- Language-specific rules (Ruby, Rails, GraphQL, Vue.js)
- Architectural standards (SOLID principles, performance optimization)

### Progressive Disclosure System

The knowledge base implements a three-tier loading system:

1. **Metadata Discovery** - Agent descriptions and command summaries for initial matching
2. **Instruction Loading** - Full prompt content loaded when agents/commands are triggered  
3. **Resource Access** - Bundled files, scripts, and references accessed on-demand

## Common Development Patterns

### Agent Invocation
Agents are automatically discovered based on task descriptions. Key patterns:

```bash
# Explicit agent invocation
> Use the sourcerer agent to analyze this codebase architecture
> Have the code-reviewer agent examine my recent changes

# Automatic discovery (based on agent descriptions)
> I need to understand how this legacy system works
# -> Triggers sourcerer agent automatically

> Fix the failing tests in the authentication module  
# -> Triggers debugger or test-coverage-analyzer agent
```

### Command Usage
Slash commands provide quick access to specialized workflows:

```bash
# Development workflows
/reviewer                    # Code review analysis
/debugger                   # Debug assistance
/implement-feature          # Feature implementation guidance
/refactor                   # Code refactoring assistance

# Specialized domains  
/rails-plan                 # Rails-specific planning
/vue-component-test         # Vue.js component testing
/security-review            # Security vulnerability analysis
```

### Skills Integration
Skills are automatically loaded when relevant tasks are detected:

- **Code Review Skill**: Triggered for code analysis and quality assessment
- **Documentation Generation Skill**: Activated for technical writing tasks
- **Testing Automation Skill**: Used for test generation and validation
- **Playwright Skill**: Loaded for browser automation and E2E testing

## Key Configuration Files

### Agent Definitions
Agent files follow standardized YAML frontmatter structure:

```yaml
---
name: agent-name
description: "Detailed description of capabilities and use cases with examples"
model: inherit|sonnet|opus|haiku
color: green|blue|red|yellow
---

System prompt content defining agent behavior, workflows, and expertise areas.
```

### Command Definitions
Commands support argument placeholders and execution context:

```markdown
---
description: Brief command description
argument-hint: [parameter1] [parameter2]
allowed-tools: Bash(command:*), Read, Write
---

Command instructions with $ARGUMENTS and $1, $2... placeholders
```

### Skills Structure
Skills use the Agent Skills specification:

```yaml
---
name: skill-name
description: What this skill does and when to use it
---

# Skill Instructions
Detailed workflow guidance, best practices, and examples.

## Resources
References to bundled scripts, templates, and documentation.
```

## Development Workflow Integration

### Quality Standards
The knowledge base enforces consistent patterns:

- **Agent Descriptions**: Must include specific use cases and examples
- **Command Documentation**: Requires clear parameter specifications
- **Skills Packaging**: Follow progressive disclosure with bundled resources
- **Rules Formatting**: Use bullet points with bold headers and code examples

### Platform Integration
Designed for seamless integration across AI development environments:

- **Claude Code**: Native agent and command discovery
- **Cursor IDE**: Specialized workflow commands and rules
- **Continue.dev**: Context-aware prompt engineering
- **API Integration**: Structured for programmatic access

### Content Organization Principles

**Domain Separation**: Clear boundaries between development areas (testing, documentation, frameworks)

**Reusability Focus**: Components designed for use across multiple projects and contexts

**Context Awareness**: Agents and commands include sufficient context to work independently

**Incremental Loading**: Large workflows broken into discoverable, composable pieces

## Important Notes

### Agent Coordination
Agents can work together in coordinated workflows:
- Sourcerer agent provides codebase analysis to other agents
- Workflow orchestrators coordinate multi-agent sequences
- Context preservation across agent boundaries

### Command Composition  
Commands can be chained for complex workflows:
- Analysis → Planning → Implementation → Testing
- Commands reference other commands and agents
- Support for background execution and progress tracking

### Skills vs Commands vs Agents
- **Skills**: Comprehensive capabilities with bundled resources
- **Commands**: Quick, single-purpose prompt templates  
- **Agents**: Persistent, stateful AI personalities with specialized expertise

### File References
Use consistent referencing patterns:
- `[filename](mdc:path/to/file)` for cross-references
- `@file/path` for file inclusion in prompts
- Absolute paths preferred for tool operations

The knowledge base serves as a comprehensive foundation for AI-enhanced development workflows, providing structured patterns for consistent, high-quality AI interactions across diverse development contexts.
