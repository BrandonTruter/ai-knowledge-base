# mcp-atlassian

## jira

### jira_create_issue

```sh
jira_create_issue(
  project_key="OMNI", 
  summary="Refactor event-driven architecture in business application flow", 
  description="Simplify and refine the UserLoanApp callbacks and event triggers", 
  issue_type="Story", 
  priority="Low",
  assignee="brandon.truter@ncino.com",
  additional_fields="{"customfield_13048": {"id": "22933", "name": "Commercial Onboarding and Account Opening"}, "priority": {"name": "High"}}"
)
```

### jira_get_issue

```sh
jira_get_issue(
  issue_key="OMNI-3111", 
  fields="*all"
)
```

```json
{
  "content": {
    "id": "3146822",
    "key": "OMNI-3111",
    "summary": "Spike: refactor plan to resolve UpsertApplicationJob code smells",
    "url": "https://ncinodev.atlassian.net/rest/api/2/issue/3146822",
    "status": {
      "name": "In Development",
      "category": "In Progress",
      "color": "yellow"
    },
    "issue_type": {
      "name": "Story"
    },
    "priority": {
      "name": "Not Prioritized"
    },
    "project": {
      "key": "OMNI",
      "name": "Omnichannel",
      "category": "BOS PDE",
      "avatar_url": "https://ncinodev.atlassian.net/rest/api/2/universal_avatar/view/type/project/avatar/21613"
    },
    "worklog": {
      "startAt": 0,
      "maxResults": 20,
      "total": 0,
      "worklogs": []
    },
    "assignee": {
      "display_name": "Brandon Truter",
      "name": "Brandon Truter",
      "email": "brandon.truter@ncino.com",
      "avatar_url": "https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/712020:48f51a6c-ebdd-4c69-a01e-680e64eed157/72d4f7da-3cde-46e2-90e7-b5dd2df0116b/48"
    },
    "reporter": {
      "display_name": "Brandon Truter",
      "name": "Brandon Truter",
      "email": "brandon.truter@ncino.com",
      "avatar_url": "https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/712020:48f51a6c-ebdd-4c69-a01e-680e64eed157/72d4f7da-3cde-46e2-90e7-b5dd2df0116b/48"
    },
    "fix_versions": [
      "Omni Web App"
    ],
    "created": "2025-05-13T05:16:18.694-0400",
    "updated": "2025-05-13T23:46:46.454-0400",
    "customfield_15076": "No",
    "customfield_13048": "OmniChannel Business"
  }
}
```

## confluence

### confluence_get_page

```sh
confluence_get_page(page_id: 5336334554, convert_to_markdown: true)
```

