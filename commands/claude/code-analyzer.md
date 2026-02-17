Execute comprehensive code analysis on all provided source files following this structured methodology.

Analysis Scope and Priorities

Examine code in strict priority order across three tiers:

Tier 1: Critical Issues

Identify and report security vulnerabilities including SQL injection, command injection, cross-site scripting (XSS), cross-site request forgery (CSRF), insecure deserialization, authentication bypass, authorization flaws, hardcoded credentials, cryptographic weaknesses, and path traversal vulnerabilities according to OWASP Top 10 standards.

Detect syntax errors preventing compilation or execution including missing semicolons, unclosed brackets, invalid operators, malformed expressions, and language-specific parsing failures.

Locate logic errors causing incorrect program behavior including null pointer dereferences, undefined variable access, incorrect conditional logic, off-by-one errors, infinite loops, unhandled edge cases, race conditions, and deadlock scenarios.

Tier 2: Performance Issues

Identify algorithmic inefficiencies including nested loops exceeding O(n log n) complexity, redundant computations, unnecessary database queries, missing indexes, inefficient data structure selection, and suboptimal search algorithms.

Detect resource management problems including memory leaks, unclosed file handles, database connection leaks, excessive memory allocation, stack overflow risks, and blocking I/O operations on main threads.

Tier 3: Code Quality Issues

Evaluate maintainability problems including excessive function length exceeding 50 lines, cyclomatic complexity above 10, deep nesting beyond 4 levels, duplicated code blocks, unclear variable naming, missing error handling, and inadequate input validation.

Assess type safety including implicit type coercion, missing type annotations in statically-typed languages, unsafe type casting, potential type mismatch errors, and violations of language-specific type system best practices.

Reporting Format Specification

- Report each issue using this exact structure:
• [SEVERITY_LEVEL] Issue_Category - filepath:line_number - Precise description of the problem and its impact

Severity Level Classification

- Apply [CRITICAL] for security vulnerabilities exposing sensitive data, syntax errors preventing execution, and logic errors causing data corruption or system crashes.
- Apply [HIGH] for logic errors producing incorrect results, performance issues degrading user experience, and type errors likely causing runtime failures.
- Apply [MEDIUM] for performance inefficiencies with measurable impact, maintainability issues hindering development, and potential runtime errors under specific conditions.
- Apply [LOW] for minor code quality improvements, style inconsistencies, and optimization opportunities with minimal impact.

Location Format Standards

- Use filename.ext:line_number for single-line issues.
- Use filename.ext:start_line-end_line for issues spanning multiple consecutive lines.
- Use filename.ext:line_number for issues where the problem originates at a specific line but affects surrounding code.

Description Requirements

- State the specific vulnerability type, affected component, and exploitation risk for security issues.
- Identify the exact syntax violation and required correction for syntax errors.
- Explain the incorrect behavior, triggering conditions, and expected correct behavior for logic errors.
- Quantify performance impact using Big O notation, execution time estimates, or resource consumption metrics for performance issues.
- Specify the violated best practice, maintainability impact, and recommended refactoring approach for code quality issues.

Analysis Constraints

- Assume production deployment environment with public internet exposure unless code comments or configuration indicate otherwise.
- Apply security standards from OWASP Top 10, CWE Top 25, and SANS Top 25 for vulnerability assessment.
- Evaluate performance assuming typical production load with concurrent users and realistic data volumes.
- Apply language-specific best practices from official style guides: PEP 8 for Python, Google Java Style for Java, Airbnb Style Guide for JavaScript, PSR-12 for PHP, and equivalent authoritative sources for other languages.
- Consider framework-specific security requirements for detected frameworks including Django, Flask, Spring, Express, React, Angular, Vue, Laravel, and Rails.

Special Handling Conditions

- Output exactly "No issues detected" when analysis reveals zero problems meeting the defined criteria.
- Output "Programming language unclear - analysis limited" followed by generic issues when file extension or syntax provides insufficient language identification.
- Prefix uncertain findings with "Potential" when static analysis cannot definitively confirm the issue without runtime context or external dependencies: • [MEDIUM] Potential Logic - file.js:12 - Description
- Group related issues affecting the same root cause under a single entry when appropriate, listing all affected line numbers.

Validation and Quality Assurance

- Verify each reported issue includes all four required components: severity level, category, location, and description.
- Confirm line numbers reference actual code lines, not blank lines or comments, unless the issue specifically involves missing code.
- Ensure descriptions provide actionable guidance enabling developers to understand and resolve the issue without additional research.
- Cross-reference security findings against CVE databases and known vulnerability patterns for the detected language version and framework version.
- Prioritize issues within each severity level by potential impact magnitude, placing data exposure risks above availability risks, and availability risks above performance degradation.
