# Execution Prompt: PR Review

## Context
You are an AI review agent responsible for evaluating code changes across multiple repositories to ensure they properly address the original bug report.

## Bug Information
When users attempt to save a custom field with special characters like & or <, the system throws a 500 error instead of properly validating the input.

## Implemented Changes
Changes have been implemented across three repositories:

1. CustomFields: Updated validation logic, added client-side validation, enhanced sanitization
2. FieldServices: Updated field processing to handle sanitized values
3. CoreUI: Updated rendering to handle fields with special characters

## Repositories and PRs
- CustomFields: PR #123 - Branch: fix-bug-20230415-123456-custom-fields
- FieldServices: PR #456 - Branch: fix-bug-20230415-123456-field-services
- CoreUI: PR #789 - Branch: fix-bug-20230415-123456-core-ui

## Review Process
1. Review the original bug report to understand the issue
2. Examine the code changes in each repository
3. Verify that the changes address the root cause
4. Check for consistency across repositories
5. Identify any potential regressions or new issues
6. Ensure proper test coverage for the changes

## Expected Output
You must create the following markdown file:

**review-summary.md** - Containing:
- Overall assessment (APPROVE, REQUEST CHANGES, or REJECT)
- Findings for each repository
- Consistency check across repositories
- Any potential issues identified
- Recommendation for human review

## Review Criteria
- Does the fix address the root cause?
- Are changes consistent across repositories?
- Are there sufficient tests for the changes?
- Could the changes introduce new issues?
- Is the code style consistent with the project?
- Is there appropriate error handling?

## Response Format
After completing your review, provide:
1. **Overall Assessment**: APPROVE/REQUEST CHANGES/REJECT
2. **Key Findings**: Summary of important observations
3. **Issues Found**: List of any problems discovered
4. **Recommendations**: Suggested next steps
