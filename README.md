# AI Knowledge Base

A comprehensive repository of curated prompts, specialized agent definitions, command libraries, and development workflows designed to enhance AI-powered development productivity. This knowledge base serves as the intellectual foundation for structured AI interactions and sophisticated development automation.

## Overview

The AI Knowledge Base transforms AI development assistance from ad-hoc prompting into structured, domain-aware knowledge application. It implements a sophisticated multi-dimensional architecture that organizes AI knowledge across complementary domains, enabling developers to leverage specialized AI capabilities seamlessly across different platforms and contexts.

### Strategic Purpose

Part of Brandon Truter's AI-Powered Development Ecosystem goal, this repository provides:
- **Reusable AI interaction patterns** for consistent, high-quality development workflows
- **Specialized agent capabilities** with domain-specific expertise
- **Cross-platform compatibility** for Claude Code, Cursor, Continue.dev, and other AI tools
- **Progressive disclosure system** that manages complexity through strategic information loading

## Repository Architecture

### 🤖 Specialized Agents (`agents/`)
Domain-expert AI personas that provide specialized capabilities:

- **`development/`** - Core development specialists (sourcerer, reviewer, debugger, optimizer)
- **`documents/`** - Content processing and documentation agents
- **`frameworks/`** - Language/framework experts (Ruby, frontend, data science)
- **`tests/`** - QA and testing automation specialists
- **`workflows/`** - Multi-step workflow orchestrators

**Example Usage:**
```bash
# Automatic discovery based on task description
> I need to understand how this legacy system works
# → Triggers sourcerer agent automatically

> Fix the failing tests in the authentication module
# → Triggers debugger or test-coverage-analyzer agent
```

### ⚡ Command Libraries (`commands/`)
Pre-built slash commands organized by AI platform:

- **`claude/`** - Claude-specific commands and workflows (49 commands)
- **`cursor/`** - Cursor IDE integration commands
- **`rails/`** - Domain-specific Rails commands (organized by category)
- **`roo/`** - Mode-based command variations (architect, code, debug, orchestrator)

**Example Commands:**
```bash
/reviewer                    # Code review analysis
/implement-feature          # Feature implementation guidance
/rails-plan                 # Rails-specific planning
/security-review            # Security vulnerability analysis
```

### 🛠️ Agent Skills (`skills/`)
Packaged capabilities following the Agent Skills specification:

- **Progressive disclosure** - Metadata → Instructions → Resources loaded on-demand
- **Bundled resources** - Scripts, templates, configuration files packaged together
- **Cross-platform compatibility** - Work seamlessly across different AI environments

**Available Skills:**
- Code Review Skill - Comprehensive code analysis and quality assessment
- Documentation Generation Skill - Technical writing and documentation automation
- Testing Automation Skill - Test generation and validation workflows
- Playwright Skill - Browser automation and E2E testing

### 📋 Rules & Standards (`rules/`)
Development standards and coding conventions:

- **Language-specific rules** (Ruby, Rails, GraphQL, Vue.js)
- **Architectural standards** (SOLID principles, performance optimization)
- **Platform-specific configurations** (Cursor rules, Claude guidelines)
- **Workflow orchestration rules** (taskmaster, debugging protocols)

### 📚 Documentation & Instructions (`documentation/`, `instructions/`)
Comprehensive guides for AI platform integration and development best practices:

- **Claude Code** integration patterns and workflow optimization
- **Continue.dev** configuration and context providers
- **Rails** domain-specific prompt engineering strategies
- **Progressive learning** patterns and teaching methodologies

## Key Features

### 🔄 Three-Tier Progressive Disclosure System

1. **Metadata Discovery** - Lightweight scanning for capability matching
2. **Instruction Loading** - Context-specific behavioral definitions loaded when triggered
3. **Resource Access** - Bundled files and scripts accessed on-demand

This system enables efficient context management while providing comprehensive capabilities when needed.

### 🤝 Agent Coordination Architecture

Sophisticated coordination patterns enable multi-agent workflows:

```
Sourcerer Agent → Architecture Analysis → Context for Other Agents
     ↓                                           ↓
Workflow Orchestrator ← Multi-Agent Sequences ← Reviewer Agent
     ↓                                           ↓
Task Distribution → Background Execution ← Progress Tracking
```

### 🎯 Platform-Specific Optimization

Each AI platform gets optimized interactions:
- **Claude** - Rich contextual analysis with memory management
- **Cursor** - IDE-integrated workflows with file manipulation
- **Continue** - Context-aware code completion and suggestion
- **Cody** - Lightweight, fast interactions for quick tasks

## Getting Started

### For Claude Code Users

1. **Agent Discovery** - Agents are automatically discovered based on task descriptions
2. **Command Usage** - Use slash commands like `/reviewer` or `/debugger` for quick access
3. **Skills Integration** - Skills load automatically when relevant tasks are detected

### For Other AI Platforms

1. **Import Relevant Components** - Copy agents, commands, or rules to your platform's configuration
2. **Adapt Format** - Modify YAML frontmatter and structure as needed for your platform
3. **Customize Behavior** - Adjust instructions for your specific development context

### Integration with NCRAFT Tools

This knowledge base provides the intellectual foundation for the NCRAFT CLI tools:
- Agent definitions inform reviewer strategy patterns
- Command libraries provide templates for CLI workflows
- Rules and standards enforce quality across automated processes

## Usage Patterns

### Automatic Agent Discovery
```bash
# Natural language triggers appropriate agents
> "Analyze the codebase architecture before making changes"
> "Review this code for security vulnerabilities"
> "Generate comprehensive tests for this component"
```

### Workflow Orchestration
```bash
# Complex development tasks coordinated across multiple agents
Analysis (sourcerer) → Planning (architect) → Implementation → Testing → Review
```

### Progressive Complexity Management
- Start with simple concepts and build complexity incrementally
- Context-aware explanations adapted to developer experience level
- Knowledge structured in logical learning hierarchies

## Contributing

When adding new components to the knowledge base:

1. **Follow Established Patterns** - Use consistent YAML frontmatter and file structures
2. **Include Examples** - Provide specific use cases and interaction examples
3. **Cross-Reference** - Link related agents, commands, and skills where appropriate
4. **Test Integration** - Verify components work across different AI platforms

## Architecture Benefits

This AI Knowledge Base delivers several key advantages:

- **Reduced Context Switching** - Domain-specific AI assistance without manual prompt crafting
- **Consistent Quality** - Standards and patterns applied automatically across interactions
- **Progressive Learning** - Complex concepts broken into manageable, discoverable pieces
- **Workflow Automation** - Multi-step processes coordinated through agent collaboration
- **Knowledge Preservation** - Domain expertise captured in reusable, discoverable formats

---

*Part of the broader ai-powered-workflows ecosystem supporting enhanced development productivity through intelligent AI assistance.*
