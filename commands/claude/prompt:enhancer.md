# Prompt Enhancer

Analyze and optimize user-submitted prompts using a structured evaluation framework. Transform prompts into clearer, more specific, and actionable versions that improve AI agent performance.

## Command Usage

**Invocation**: `/improve-prompt` or `@improve-prompt`

**Input Methods**:
1. User pastes prompt text directly in chat
2. User provides file path: `improve-prompt path/to/prompt.md`
3. User references existing prompt: `improve-prompt @existing-prompt-name`

**Output**: Enhanced prompt file saved to `.cursor/commands/improved-[original-name].md` with analysis report

## Analysis Framework

Evaluate prompts across five dimensions, each with specific criteria:

### 1. Clarity Assessment
- **Ambiguous terms**: Identify undefined technical terms, jargon, or abstract concepts
- **Vague instructions**: Locate directives lacking actionable steps (e.g., "make it better" vs "increase specificity by 40%")
- **Missing context anchors**: Flag references without clear definitions (e.g., "the system" without specifying which system)
- **Abstract concepts**: Document ideas requiring concrete examples (e.g., "user-friendly" needs UI mockups or behavior descriptions)

**Scoring**: Rate each issue as High/Medium/Low impact on comprehension

### 2. Specificity Validation
- **Parameter gaps**: List missing required inputs (types, formats, constraints)
- **Quantitative holes**: Identify missing metrics (thresholds, limits, percentages, counts)
- **Format ambiguity**: Note unclear output specifications (structure, length, style)
- **Boundary undefined**: Flag missing scope limitations (what's in/out of scope)

**Scoring**: Rate each gap as Critical/Important/Nice-to-have

### 3. Context Sufficiency
- **Background missing**: Identify required domain knowledge not provided
- **Use case gaps**: Note missing scenarios or application contexts
- **Constraint omissions**: Flag missing environmental, technical, or business constraints
- **Stakeholder undefined**: Note missing audience or user type specifications

**Scoring**: Rate each gap as Blocks-execution/Reduces-quality/Enhances-understanding

### 4. Structural Integrity
- **Logical flow issues**: Identify sequencing problems or missing dependencies
- **Organization problems**: Note hierarchical or grouping issues
- **Terminology inconsistency**: Flag repeated terms with different meanings
- **Modularity gaps**: Identify sections that should be split or combined

**Scoring**: Rate each issue as Breaks-execution/Confuses-reader/Reduces-clarity

### 5. Output Format Specification
- **Format undefined**: Note missing structure requirements (markdown, JSON, code blocks)
- **Length unspecified**: Flag missing word/page/character limits
- **Style missing**: Note absent style guides or formatting requirements
- **Evaluation criteria absent**: Flag missing success metrics or quality benchmarks

**Scoring**: Rate each gap as Prevents-use/Reduces-quality/Enhances-output

## Improvement Process

Execute four sequential phases:

### Phase 1: Issue Documentation
1. Generate categorized problem list with specific examples from the prompt
2. Assign severity scores (High/Critical = must fix, Medium/Important = should fix, Low/Nice-to-have = could fix)
3. Create priority-ordered correction list focusing on execution blockers first
4. Document missing elements that prevent optimal performance
5. Catalog ambiguities with proposed resolution strategies

**Deliverable**: Issue inventory with 5-15 specific problems, each with:
- Exact quote from original prompt
- Problem category (Clarity/Specificity/Context/Structure/Format)
- Severity level (High/Medium/Low)
- Impact description (what fails without this fix)
- Proposed solution approach

### Phase 2: Enhancement Strategy
1. Design targeted fixes for each High/Critical issue
2. Specify concrete modifications with before/after examples
3. Develop context integration plan (what background to add, where)
4. Create structural optimization (reorganization, flow improvements)
5. Formulate constraint specifications (boundaries, limitations)

**Deliverable**: Improvement plan with:
- Specific change recommendations (10-20 items)
- Rationale for each change
- Expected impact on each assessment dimension
- Implementation complexity (Simple/Moderate/Complex)

### Phase 3: Prompt Reconstruction
1. Rewrite prompt implementing all High/Critical fixes
2. Integrate specific examples demonstrating desired outcomes
3. Embed relevant context (use cases, constraints, audience)
4. Define precise output format with templates
5. Include step-by-step execution instructions
6. Establish measurable success criteria
7. Clarify target audience and expertise assumptions

**Deliverable**: Enhanced prompt that:
- Maintains original intent
- Increases specificity by 50%+ (measured by concrete parameters)
- Includes 3-5 concrete examples
- Has clear success criteria
- Is immediately actionable without clarification

### Phase 4: Change Documentation
1. List all modifications with before/after comparisons
2. Explain improvement rationale for each major change
3. Document technique applications (which optimization methods used)
4. Provide alternative approaches for different contexts
5. Suggest optional enhancements for specialized use cases

**Deliverable**: Change log with:
- Summary table (Issue → Fix → Impact)
- Detailed explanations for top 5-10 improvements
- Alternative approaches for 2-3 key decisions
- Optional refinements list

## Response Structure

Generate analysis using this exact format:
own
## Prompt Analysis Report

### Original Prompt
[Full text of submitted prompt]

### Issue Inventory

#### Clarity Issues (High Priority: X, Medium: Y, Low: Z)
- [Specific quote]: [Problem description] - [Impact] - [Severity]

#### Specificity Gaps (Critical: X, Important: Y, Nice-to-have: Z)
- [Specific quote]: [Missing element] - [Impact] - [Severity]

#### Context Deficiencies (Blocks: X, Reduces: Y, Enhances: Z)
- [Specific quote]: [Missing context] - [Impact] - [Severity]

#### Structural Problems (Breaks: X, Confuses: Y, Reduces: Z)
- [Specific quote]: [Structure issue] - [Impact] - [Severity]

#### Format Ambiguities (Prevents: X, Reduces: Y, Enhances: Z)
- [Specific quote]: [Format issue] - [Impact] - [Severity]

### Enhanced Prompt

[Complete rewritten prompt with all improvements]

### Improvement Summary

| Issue Category | Issues Found | Fixed | Improvement Impact |
|---------------|--------------|-------|-------------------|
| Clarity | X | X | [Description] |
| Specificity | Y | Y | [Description] |
| Context | Z | Z | [Description] |
| Structure | A | A | [Description] |
| Format | B | B | [Description] |

### Key Improvements

1. **[Improvement Name]**: [What changed] - [Why it matters] - [Measurable impact]
2. **[Improvement Name]**: [What changed] - [Why it matters] - [Measurable impact]
[... continue for top 5-10 improvements]

### Alternative Approaches

- **Option A**: [Alternative approach] - [When to use] - [Trade-offs]
- **Option B**: [Alternative approach] - [When to use] - [Trade-offs]

### Optional Enhancements

- [Enhancement suggestion] - [Benefit] - [Complexity]
- [Enhancement suggestion] - [Benefit] - [Complexity]## Quality Standards

**Intent Preservation**: Maintain original purpose while improving execution clarity

**Measurable Improvement**:
- Specificity increase: 50%+ more concrete parameters
- Clarity increase: Reduce ambiguous terms by 70%+
- Actionability: Prompt should be executable without additional questions

**Professional Presentation**:
- Use clear headings and structured sections
- Include code blocks and examples where helpful
- Follow markdown best practices

**Output Location**: Save enhanced prompt to `.cursor/commands/improved-[name].md` and analysis report to `.cursor/commands/analysis-[name].md`

## Error Handling

**Invalid Input**: If prompt is too short (<50 words) or too long (>5000 words), request clarification on scope

**Ambiguous Request**: If original prompt's intent is unclear, ask 2-3 clarifying questions before analysis

**Analysis Failure**: If systematic analysis fails, provide basic improvements focusing on clarity and specificity

## Examples

### Example 1: Simple Prompt Improvement
**Input**: "Make a login page"
**Analysis**: Missing UI framework, design requirements, authentication method, user flow
**Output**: Enhanced prompt with specific framework (React/Vue), design system reference, authentication flow, and acceptance criteria

### Example 2: Complex Prompt Improvement
**Input**: Technical prompt with 500+ words but vague instructions
**Analysis**: Identify 15+ specific issues across all dimensions
**Output**: Comprehensive rewrite with examples, templates, and structured sections
