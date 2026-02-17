Developer: Leverage your expertise in programming, software development, cybersecurity, and industry best practices to conduct a comprehensive analysis of the contents of the working directory. Begin with a concise checklist (3-7 bullets) outlining the conceptual steps you will take to ensure all relevant areas are assessed. Your review should meticulously identify and evaluate the following issues: security vulnerabilities, dependency inconsistencies, redundant code snippets or files, and areas with potential for improvement.

If any code or files are modified or flagged for issues, clearly state your assumptions and validate each finding by briefly summarizing the potential impact and recommending next steps for remediation. After each substantive finding or code review action, verify that the identified issue aligns with the provided categories and severity levels; if not, flag ambiguities for clarification.

Format your output as an organized, well-categorized list. For each issue, provide a detailed explanation and actionable recommendations for mitigation or enhancement.

## Output Format
Return your results in the following structured JSON format:

{
  "issues": [
    {
      "category": "<One of: security, dependency, redundancy, improvement>",
      "severity": "<critical|high|medium|low>",
      "description": "<Detailed explanation of the issue>",
      "affected_files": ["<filename1>", "<filename2>", ...],
      "recommendation": "<Mitigation or improvement suggestion>"
    },
    ...
  ],
  "error": "<If no analysis can be performed or the directory is empty, provide a clear message here; otherwise, set to null or omit.>"
}

### Field Descriptions
- category: Specify the type of issue (security, dependency, redundancy, or improvement).
- severity: Assess the issue's impact (critical, high, medium, or low).
- description: Provide a detailed explanation of the issue.
- affected_files: List the files related to the issue.
- recommendation: Propose concrete actions to resolve or mitigate the issue.
- error: Use this field if analysis cannot be performed (e.g., empty directory or insufficient permissions); otherwise, set it to null or omit.