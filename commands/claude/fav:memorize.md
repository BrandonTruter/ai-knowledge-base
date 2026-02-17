# Conversation Continuity Documentation Generator

## Primary Objective
Generate comprehensive session documentation that enables seamless context transfer between AI conversations while preserving critical project state, technical decisions, and implementation progress.

## Input Requirements
- Complete conversation history from current session
- Active file modifications and their current states
- Pending tasks with associated priority levels
- Technical solutions implemented during session
- Error resolutions and debugging outcomes

## Documentation Structure

### Session Overview Section
Document conversation duration, primary focus areas, and completion percentage of planned objectives. Include participant roles, decision-making authority, and escalation requirements.

### Technical Progress Tracking
Record specific code changes, file modifications, configuration updates, and system integrations completed. Include version control commits, deployment status, and testing results with pass/fail metrics.

### Active File Inventory
List all files accessed, modified, or created during session with:
- Full file paths and current modification timestamps
- Change summaries with line-level impact assessment
- Dependency relationships and integration points
- Validation status and quality assurance completion

### Solution Implementation Record
Document technical solutions provided with:
- Problem statements and root cause analysis
- Implementation approaches with rationale
- Code examples and configuration snippets
- Performance impact measurements
- Rollback procedures and risk mitigation strategies

### Context Restoration Protocol
Specify exact files requiring immediate access in subsequent sessions:
- Configuration files with current parameter values
- Documentation files containing project specifications
- Code files with pending modifications
- Test files with current coverage metrics

### Task Completion Framework
Define remaining work items using:
- Specific acceptance criteria with measurable outcomes
- Implementation sequence with dependency mapping
- Resource requirements and time estimates
- Quality gates and validation checkpoints
- Reference examples with expected output formats

## Output Specifications

### File Generation Requirements
Create markdown file at ~/Desktop/conversation_summary_[YYYY-MM-DD-HHMM].md with:
- Hierarchical section organization using H1-H4 headers
- Code blocks with language specification and file paths
- Task lists with completion status indicators
- Cross-reference links to related documentation

### Content Quality Standards
Ensure documentation contains:
- Zero ambiguous references or undefined terminology
- Quantified progress metrics and completion percentages
- Actionable next steps with specific implementation guidance
- Technical context sufficient for immediate work resumption
- Validation criteria for each pending task

### Continuity Validation Checklist
Verify documentation enables:
- Immediate project context understanding within 2 minutes
- Direct continuation of technical work without clarification requests
- Accurate assessment of project completion status
- Identification of critical path dependencies and blockers

## Execution Protocol
Process conversation history chronologically, extract technical decisions and implementations, categorize pending work by priority and complexity, generate structured documentation following specified format, validate completeness against continuity requirements, save file with timestamp-based naming convention.

## Success Metrics
Documentation quality measured by:
- Context restoration time under 2 minutes in subsequent sessions
- Zero clarification requests for previously discussed topics
- Successful continuation of technical implementations
- Accurate project status assessment and progress tracking
