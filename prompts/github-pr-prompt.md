# GitHub Pull Request Creation Prompt

Create a GitHub pull request with the following specifications:

1. Source branch: [Automatically detect the current branch in the developer's IDE/environment]
2. Target branch: release
3. Use the project's pull request template located at .github/pull_request_template.md
   - Preserve the entire structure of the template including all sections, checkboxes, and formatting
   - Do not remove any sections or elements from the template, even if they seem irrelevant
   - For checkbox lists (like metadata changes), only check boxes that apply to the current changes
   - If no items in a checkbox list apply, leave all checkboxes unchecked
   - If a section is not applicable, leave it in place but add "N/A" or similar indication
4. Fill out all required fields in the template with appropriate information based on the changes in the current branch
5. Include a descriptive title that starts with the ticket number (extracted from the branch name if it follows a pattern like "XX-1234") followed by a brief description of the changes
6. Add relevant team members as reviewers based on the areas of code modified
7. Apply appropriate labels to the pull request based on the nature of the changes (e.g., bug, feature, enhancement)
8. If there are any associated tasks or issues, link them in the pull request description
9. Include a robust, detailed description that:
   - Clearly explains the purpose and impact of the changes
   - Summarizes the main functional changes implemented
   - Lists any architectural or significant implementation decisions
   - Notes any potential side effects or considerations for reviewers
   - Explains how the changes were tested
10. Before submitting, verify that all required fields in the template are completed and the description provides comprehensive context for reviewers

Please create this pull request now.
