# Code Review with Suggested Fixes

Analyze the provided code for issues across these categories, listed in priority order, and provide specific fix recommendations for each issue found:

## Critical Issues (Report First)
- Security vulnerabilities (authentication, authorization, injection, XSS, CSRF, etc.)
- Syntax errors that prevent compilation/execution
- Logic errors causing incorrect behavior or crashes

## Important Issues
- Performance problems (inefficient algorithms, memory leaks, blocking operations)
- Code quality issues (maintainability, readability, best practices)
- Type safety problems and potential runtime errors

## Analysis Requirements
- Specify file path and line number for each issue: `filename.ext:line_number`
- For multi-line issues, use range format: `filename.ext:start_line-end_line`
- Include issue severity: `[CRITICAL]`, `[HIGH]`, `[MEDIUM]`, `[LOW]`
- Provide specific, actionable descriptions
- **Include concrete fix suggestion for each issue**

## Output Format
```
• [SEVERITY] Issue_Category - filename.ext:line_number - Brief description
  Fix: Specific code change or approach to resolve the issue
  
• [SEVERITY] Issue_Category - filename.ext:line_number - Brief description  
  Fix: Specific code change or approach to resolve the issue
```

## Example Output
```
• [CRITICAL] Security - auth.js:45 - SQL injection vulnerability in user query
  Fix: Use parameterized queries: `db.query('SELECT * FROM users WHERE id = ?', [userId])`

• [HIGH] Logic - calculator.js:23 - Division by zero not handled
  Fix: Add validation: `if (divisor === 0) throw new Error('Division by zero')`

• [MEDIUM] Performance - data.js:67 - Inefficient nested loop (O(n²))
  Fix: Use Map for lookup: `const map = new Map(arr1.map(item => [item.id, item]))`

• [LOW] Style - utils.js:12 - Variable name not descriptive
  Fix: Rename `d` to `dateString` or `formattedDate`
```

## Fix Categories & Guidelines

### Security Fixes
- **Input Validation**: Add sanitization, type checking, length limits
- **SQL Injection**: Use parameterized queries, ORMs, prepared statements  
- **XSS Prevention**: Escape output, use Content Security Policy
- **Authentication**: Implement proper session management, password hashing
- **Authorization**: Add role-based access controls, permission checks

### Logic Fixes
- **Null/Undefined Checks**: Add defensive programming with proper validation
- **Error Handling**: Implement try-catch blocks, graceful degradation
- **Edge Cases**: Handle boundary conditions, empty arrays, missing properties
- **Type Coercion**: Use strict equality, explicit type conversion

### Performance Fixes
- **Algorithm Optimization**: Replace O(n²) with O(n log n) or O(n) solutions
- **Memory Management**: Fix leaks, reduce object creation, use weak references
- **Database**: Add indexes, optimize queries, implement caching
- **Async Operations**: Use Promise.all(), avoid blocking operations

### Code Quality Fixes
- **Naming**: Use descriptive variable/function names following conventions
- **Structure**: Extract functions, reduce complexity, improve modularity
- **Documentation**: Add JSDoc comments, type annotations, README updates
- **Standards**: Follow language-specific style guides (ESLint, Prettier, etc.)

## Special Cases
- If no issues found, respond: "✅ No issues detected"
- If code language cannot be determined, state: "⚠️ Programming language unclear - analysis limited"
- For uncertain issues, prefix with "Potential": `• [MEDIUM] Potential Logic - file.js:12 - ...`
- If fix requires architectural changes, note: "Fix: Requires refactoring - [brief approach]"

## Fix Implementation Priority
1. **CRITICAL**: Implement immediately - security and blocking issues
2. **HIGH**: Address in current sprint - functionality and major performance
3. **MEDIUM**: Include in next release cycle - optimization and quality
4. **LOW**: Address during refactoring - style and minor improvements

## Scope & Standards
- Focus on functional correctness, security, and performance
- Assume production environment unless otherwise specified
- Apply industry-standard security practices (OWASP Top 10)
- Consider modern best practices for the detected programming language
- Provide fixes compatible with existing codebase architecture
- Suggest incremental improvements over complete rewrites when possible