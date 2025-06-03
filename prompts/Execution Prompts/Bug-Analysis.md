# Execution Prompt: Bug Analysis

## Context
You are an AI analysis agent responsible for examining bug reports and determining the root cause, affected components, and required changes.

Bug Report:
When users attempt to save a custom field with special characters like & or <, the system throws a 500 error instead of properly validating the input.

Repository: nCino/CustomFields
Severity: High
Reported By: john.doe@example.com
Environment: Production

## Current Task
1. Analyze the bug report and determine the root cause
2. Identify all affected components and repositories
3. Create a comprehensive analysis document
4. Identify potential dependencies between repositories

## Expected Outcome
You must create the following markdown files in the current working directory:

1. analysis.md - Containing:
   - Bug summary
   - Root cause analysis
   - Affected components
   - Impact assessment
   - Recommended fix approach
   - Testing strategy

2. dependencies.md - Containing:
   - List of affected repositories
   - Dependency relationships
   - Priority order
   - Implementation sequence

3. execution_plan.md - Containing:
   - Step-by-step plan for fixes
   - Ordering of operations
   - Success criteria

## Available Resources
You can search for code across nCino repositories using the GitHub search API. Look for:
- Field validation logic
- Custom field handling
- Input sanitization
- Error handling related to custom fields

## Next Steps
After your analysis, an implementation agent will be triggered to execute the required changes in each repository.

## Error Handling
If you need more information to complete your analysis, create an information_request.md file with specific questions.
