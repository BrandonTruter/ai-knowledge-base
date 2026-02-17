# Code Refactoring Analysis Request

## Code Submission
Please provide the source code requiring refactoring analysis. Include:
- **File path(s):** Specify location within project structure
- **Programming language:** [Language name and version]
- **Code context:** Brief description of functionality and business domain
- **Current pain points:** Known issues or maintenance challenges

## Analysis Requirements

### Primary Refactoring Objectives (in priority order):
1. **Function Extraction:** Identify code duplication (3+ lines repeated 2+ times)
2. **Naming Optimization:** Flag unclear variables/functions using descriptive naming conventions
3. **Conditional Simplification:** Target nested conditionals (3+ levels) and complex boolean expressions
4. **SOLID Principles Application:** Focus on Single Responsibility and Dependency Inversion violations
5. **Coupling Reduction:** Identify tight dependencies between classes/modules
6. **Testability Enhancement:** Highlight hard-to-test code patterns and dependencies

### Scope Parameters
- **Codebase size:** [Small: <500 lines | Medium: 500-2000 lines | Large: 2000+ lines]
- **Refactoring budget:** [Conservative: minimal changes | Moderate: structural improvements | Aggressive: architectural redesign]
- **Compatibility requirements:** [Backward compatibility needs, API stability requirements]

## Desired Output Format

### 1. Executive Summary
- Overall code quality assessment (1-10 scale)
- Top 3 critical refactoring priorities
- Estimated effort level for each improvement category

### 2. Detailed Analysis by Category
For each refactoring objective, provide:

**Issue Identification:**
```language:filepath
// Original problematic code snippet
```

**Proposed Solution:**
```language:filepath
// Refactored code implementation
```

**Improvement Rationale:**
- Specific SOLID principle applied
- Testability enhancement explanation
- Maintenance benefit description

### 3. Implementation Roadmap
- **Phase 1 (Low Risk):** Safe refactoring with minimal behavior changes
- **Phase 2 (Medium Risk):** Structural improvements requiring testing
- **Phase 3 (High Risk):** Architectural changes requiring coordination

### 4. Testing Strategy
- Unit test recommendations for refactored components
- Integration test considerations
- Regression testing checkpoints

## Quality Criteria
- **Maintainability:** Reduced cyclomatic complexity (target: <10 per function)
- **Readability:** Self-documenting code requiring minimal comments
- **Testability:** 90%+ code coverage achievable with unit tests
- **Performance:** No degradation in critical path operations
- **Extensibility:** New features implementable with minimal existing code changes

## Additional Context (Optional)
- **Team expertise level:** [Junior | Mixed | Senior]
- **Existing test coverage:** [Percentage and test types]
- **Performance constraints:** [Critical performance requirements]
- **Deployment frequency:** [Release cycle affecting refactoring scope]

Please analyze the submitted code and deliver comprehensive refactoring recommendations following this structured approach.

