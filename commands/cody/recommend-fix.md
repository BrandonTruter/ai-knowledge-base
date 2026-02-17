Perform a comprehensive code quality review of the provided code selection and deliver actionable improvement recommendations.

**INPUT SOURCE**
Analyze the code currently selected in the editor (referenced via cody://selection).

**EVALUATION CRITERIA**
Assess the code across these dimensions:
- Code smells and anti-patterns
- Readability and code clarity
- Maintainability and extensibility
- Performance optimization opportunities
- Security vulnerabilities and risks
- Error handling robustness
- Testing and testability
- Documentation completeness
- Adherence to language-specific best practices and idioms

**ANALYSIS CONSTRAINTS**
- Focus exclusively on improvement opportunities, not existing implementations that already follow best practices
- Exclude issues that the code demonstrably addresses or mitigates
- Prioritize recommendations by impact: critical security/performance issues first, then maintainability, then style improvements

**OUTPUT REQUIREMENTS**

Provide up to 5 prioritized recommendations using this structure:

**[Priority Level]: [Issue Category] - [Brief Title]**
- **Current State**: Describe what the code currently does
- **Recommendation**: Specific actionable change to implement
- **Benefits**: Concrete advantages (e.g., "Reduces time complexity from O(n²) to O(n)", "Prevents SQL injection attacks", "Improves code reusability")
- **Code Example** (if applicable): Brief before/after snippet demonstrating the change

**SUMMARY ASSESSMENT**
Conclude with one of these evaluations:
- "**Critical improvements needed**: [X] high-priority issues identified that impact [security/performance/reliability]"
- "**Moderate improvements available**: Code is functional but [X] enhancements would improve [specific qualities]"
- "**Code follows sound design principles**: Only minor refinements suggested, no significant issues identified"
- "**No improvements identified**: Code demonstrates excellent quality across all evaluation criteria"

**SPECIAL CASES**
- If the code selection is empty, incomplete, or not analyzable, respond: "Unable to analyze: [specific reason]"
- If the code is in a language/framework you cannot evaluate, respond: "Analysis unavailable for [language/framework]"

**CONTEXT ADAPTATION**
Automatically detect and apply appropriate standards based on:
- Programming language and version
- Apparent framework or library usage
- Code context (production, test, configuration, etc.)
- Complexity level and project scale indicators
