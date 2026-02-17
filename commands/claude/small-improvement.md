**CODE IMPROVEMENT ANALYSIS REQUEST**

**OBJECTIVE**: Identify and recommend the single highest-impact, low-effort code improvement from recent local changes.

**ANALYSIS SCOPE**:
- **Primary Target**: Git-tracked changes (staged, unstaged, or recent commits within last 7 days)
- **Fallback Scope**: If no git changes exist, analyze all code files in current directory and subdirectories
- **File Types**: Focus on common programming languages (.py, .js, .ts, .java, .cpp, .c, .go, .rs, .php, .rb)
- **Analysis Depth**: Examine up to 500 lines of changed code or 10 modified files, whichever is encountered first

**IMPROVEMENT CRITERIA** (prioritized by ROI):
1. **Critical Issues**: Security vulnerabilities, memory leaks, or logic errors
2. **High-Impact/Low-Effort**: Function extraction, variable renaming, error handling addition
3. **Maintainability Gains**: Code duplication removal, magic number elimination
4. **Readability Enhancements**: Comment addition, complex expression simplification
5. **Performance Optimizations**: Algorithm improvements, unnecessary computation removal

**EFFORT CONSTRAINTS**:
- **Minimal Refactoring**: Changes requiring <30 minutes implementation time
- **No Breaking Changes**: Modifications that preserve existing API contracts
- **Single File Focus**: Improvements contained within one file when possible

**REQUIRED OUTPUT FORMAT**:

**1. ANALYSIS SUMMARY**
- Files analyzed: [count and file paths]
- Code change detection method: [git diff/directory scan]
- Total lines of code examined: [number]

**2. RECOMMENDED IMPROVEMENT**
- **File**: `path/to/file.ext`
- **Location**: Lines X-Y or Function name
- **Type**: [Function extraction/Variable naming/Error handling/etc.]
- **Effort Estimate**: [X minutes]

**3. IMPLEMENTATION DETAILS**
```language:filepath
[Specific code showing before/after or implementation example]
```

**4. IMPACT JUSTIFICATION**
- **Quality Benefit**: [Specific improvement description]
- **ROI Explanation**: [Why this change provides maximum value for minimal effort]
- **Risk Assessment**: [Potential issues and mitigation strategies]

**FALLBACK RESPONSES**:
- If no code found: "No analyzable code files detected in current directory"
- If no improvements needed: "Code quality appears optimal; no high-ROI improvements identified"
- If multiple equal-value improvements exist: Prioritize by implementation speed

**EXECUTION PARAMETERS**:
- Maximum analysis time: 2 minutes
- Focus on actionable, specific recommendations
- Include concrete code examples when beneficial
- Provide implementation guidance for complex changes
