# 1 Epic Analysis Review

# Phase 1: Epic Context

Start by gathering thorough epic context using your AI assistant:

```md
Analyze epic [EPIC-KEY] to understand:
- Business objectives and success metrics
- User personas and their workflows
- System integrations and external dependencies
- Design assets and user journey complexity
- Compliance and regulatory requirements
- Current team capacity and skill alignment

Provide a foundation assessment covering scope complexity,
integration points, and potential breakdown challenges.
```

2. Stakeholder Alignment

Identify and align with key stakeholders:

```md
Review epic [EPIC-KEY] against these quality criteria:
1. Clear business value and success metrics defined
2. User personas and workflows documented
3. Design assets available and accessible
4. Acceptance criteria includes compliance requirements
5. External integrations identified with API documentation
6. Non-functional requirements specified

For each criterion, provide:
- Current status (Complete/Partial/Missing)
- Specific gaps or concerns
- Recommended actions before breakdown
```

# 2: Story Identification & User Journey Mapping

# Phase 1: Epic Foundation Validation

```
Review epic [EPIC-KEY] against these quality criteria:
1. Clear business value and success metrics defined
2. User personas and workflows documented
3. Design assets available and accessible
4. Acceptance criteria includes compliance requirements
5. External integrations identified with API documentation
6. Non-functional requirements specified

For each criterion, provide:
- Current status (Complete/Partial/Missing)
- Specific gaps or concerns
- Recommended actions before breakdown
```

# Phase 2: Story Identification & User Journey Mapping

```
Based on epic [EPIC-KEY], identify stories using this systematic approach:

IMPORTANT: Do not create or update any Jira tickets during this analysis. Only provide the story identification and analysis.

1. USER JOURNEY MAPPING
Map complete user workflows for each persona:
- Entry points and authentication flows
- Data collection and validation steps
- Decision points and approval workflows
- Error handling and recovery scenarios
- Integration touchpoints with external systems

2. COMPONENT ANALYSIS
Break down by system architecture:
- BOS/Salesforce: LWC components, Apex controllers, Flow automation
- CB API: Lambda functions, TypeScript interfaces, DynamoDB operations
- Omnichannel: Ruby controllers, Vue.js components, MySQL operations
- External Integrations: API wrappers, authentication, error handling

3. STORY CATEGORIZATION
Organize identified stories by type:
- UI/UX Stories: User interface components and interactions
- Backend/API Stories: Data services and business logic
- Integration Stories: External system connections
- Analytics Stories: Tracking and reporting requirements
- Testing Stories: Automated test creation and validation

For each identified story, provide:
- Story title and brief description
- Estimated complexity (S/M/L/XL)
- Dependencies on other stories or external systems
- Testing requirements and scenarios

Use these Consumer Banking Story Templates as reference:

UI/UX Story Template:
Title: [Component/Page Name] - [User Action]

As a [persona]
I want [capability]
So that [business value]

Acceptance Criteria:
- [ ] UI matches Figma design (Node ID: [node-id])
- [ ] Responsive design for 1024px+ resolution
- [ ] Accessibility compliance (WCAG 2.1 AA)
- [ ] Loading states during API calls
- [ ] Error handling with user-friendly messages
- [ ] Integration with BOS/CB API/Omnichannel data flows

Design References:
- Figma Node: [node-id]
- Interaction Pattern: [pattern-type]
- Component Library: [SLDS/Custom]

Definition of Done:
- [ ] Component developed and unit tested
- [ ] Integration testing with backend services
- [ ] Automated UI tests created
- [ ] Cross-browser compatibility verified
- [ ] Design review approval obtained

Integration Story Template:
Title: [System Integration] - [Data Operation]

As a [system/service]
I want [integration capability]
So that [business process enabled]

Technical Requirements:
- [ ] API endpoint: [URL and method]
- [ ] Authentication: [method and credentials]
- [ ] Rate limiting: [requests per minute/hour]
- [ ] Error handling: [retry logic and fallback]
- [ ] Data transformation: [input/output schemas]

Consumer Banking Context:
- [ ] BOS integration patterns followed
- [ ] Data stored in appropriate objects (Account, Opportunity, Custom)
- [ ] Field mapping documented and validated
- [ ] Compliance data handling (PII, financial data)

Definition of Done:
- [ ] Integration service developed with error handling
- [ ] Unit tests covering success and failure scenarios
- [ ] Integration tests with sandbox/staging environment
- [ ] Performance testing for expected load
- [ ] Documentation updated with API specifications
- [ ] Monitoring and alerting configured
```

# Phase 3: Story Ticket Creation & Estimation

```
For each story identified in Phase 2, create detailed story specifications:

IMPORTANT: Do not create actual Jira tickets. Only provide the detailed specifications for manual ticket creation.

1. STORY DETAILS
- Clear title following naming conventions
- Detailed acceptance criteria with testable conditions
- Technical implementation notes specific to Consumer Banking architecture
- Design references with Figma node IDs
- Integration specifications with API documentation links

2. ESTIMATION APPROACH
Use story points based on this framework:

Story Point Estimation Framework:
- 1 Point: Simple CRUD operations, standard UI components, clear requirements
- 2 Points: Basic business logic, single integration, standard testing
- 3 Points: Moderate complexity business logic, multiple integrations, custom UI components
- 5 Points: Complex business logic, external API integration, custom workflows
- 8 Points: Major feature with multiple integrations, complex user flows, extensive testing
- 13+ Points: Epic-level work requiring further breakdown

Consumer Banking Complexity Factors:
- BOS/Salesforce Integration: +1-2 points for custom objects, flows, and LWC components
- External API Integration: +2-3 points for JD Power, Alloy, Credit Bureau integrations
- Multi-System Data Flow: +1-2 points for data synchronization across systems
- Compliance Requirements: +1-2 points for KYC, AML, regulatory validation
- Custom User Workflows: +1-2 points for non-standard approval or decision logic

3. DEFINITION OF DONE INTEGRATION
Include automated testing requirements:
- Unit test coverage expectations (80%+ for business logic)
- Integration test scenarios (happy path and error conditions)
- End-to-end test cases (user workflow validation)
- Performance test criteria (response time and load handling)

Generate story specifications with complete context for immediate development work.
```

# Phase 4: Dependency Analysis & Parallel Development Planning

```
Analyze all stories from Phase 3 to identify dependencies:

1. TECHNICAL DEPENDENCIES
- API development must precede UI implementation
- Database schema changes required before business logic
- Authentication services needed for secure endpoints
- External system integrations required for data validation

2. BUSINESS PROCESS DEPENDENCIES
- Customer onboarding before loan application
- Credit check completion before offer generation
- Collateral valuation before loan approval
- Approval workflow before customer notification

3. DESIGN DEPENDENCIES
- Component library updates before UI implementation
- User flow approval before development start
- Accessibility review before production deployment

4. TESTING DEPENDENCIES
- Unit tests developed alongside implementation
- Integration tests after API completion
- End-to-end tests after full workflow implementation

Create a dependency graph showing:
- Critical path stories that cannot be parallelized
- Story clusters that can be developed simultaneously
- External dependencies requiring coordination
- Risk mitigation for high-dependency areas

Provide recommendations for:
- Sprint planning and story sequencing
- Team allocation for parallel work streams
- Milestone planning for external dependency coordination
```

# Phase 5: Quality Gates & Validation

```
Review the complete story breakdown for epic [EPIC-KEY]:

1. COMPLETENESS CHECK
Verify all user journeys have corresponding stories
Confirm no gaps between epic acceptance criteria and story coverage
Validate external integration points are properly captured

2. CONSISTENCY CHECK
Ensure consistent story formats and acceptance criteria structure
Verify estimation consistency across similar story types
Confirm design reference consistency and accessibility

3. FEASIBILITY CHECK
Review timeline estimates against team capacity
Identify potential bottlenecks in critical path
Assess external dependency risks and mitigation strategies

4. QUALITY CHECK
Use this validation checklist for each story ticket:

COMPLETENESS
- [ ] Clear, testable acceptance criteria
- [ ] Technical implementation approach documented
- [ ] Design references with accessible Figma links
- [ ] Integration specifications with API documentation
- [ ] Error handling requirements specified
- [ ] Performance criteria defined

CONSUMER BANKING CONTEXT
- [ ] System architecture alignment (BOS/CB API/Omnichannel)
- [ ] Data model integration with existing objects
- [ ] User persona workflow alignment
- [ ] Compliance requirements addressed
- [ ] Security considerations documented

DEVELOPMENT READINESS
- [ ] All dependencies identified and documented
- [ ] Prerequisites completed or scheduled
- [ ] Team capacity aligned with story complexity
- [ ] Testing strategy defined and actionable
- [ ] Definition of Done includes automated testing

Validate automated testing coverage across all stories
Confirm Definition of Done alignment with team standards
Ensure Consumer Banking architecture patterns followed

Provide specific recommendations for:
- Stories requiring additional detail or clarification
- Estimation adjustments based on complexity analysis
- Risk mitigation for high-uncertainty areas
- Sprint planning optimizations for parallel development
```

# Phase 6: Epic Breakdown Completion & Execution Setup

```
Complete the epic breakdown process:

1. STORY PRIORITIZATION
Sequence stories for optimal development flow:
- Foundation stories (authentication, data models) first
- Core workflow stories in logical user journey order
- Integration stories aligned with external system availability
- Enhancement stories after core functionality completion

2. SPRINT PLANNING INTEGRATION
Organize stories into sprint-sized increments:
- Consider team capacity and story point velocity
- Balance technical and user-facing stories within sprints
- Account for dependencies and critical path constraints
- Plan demo-ready increments for stakeholder feedback

3. EXECUTION MONITORING SETUP
Define tracking mechanisms:
- Story completion criteria and review checkpoints
- Integration testing milestones for external dependencies
- User acceptance testing coordination with business stakeholders
- Performance testing gates before production deployment

4. RISK MITIGATION PLANNING
Document identified risks and mitigation strategies:
- External API changes or availability issues
- Design approval delays or requirement changes
- Team capacity changes or skill gap identification
- Technical complexity discoveries requiring story adjustments

Generate execution roadmap with:
- Sprint-by-sprint story allocation
- Milestone markers for external dependencies
- Risk monitoring checkpoints
- Success criteria validation points
```

---

Validation Through Test Application:

Before considering the methodology complete, validate by applying to a current Consumer Banking epic:


```
Apply this methodology to upcoming epic [TEST-EPIC-KEY]:

1. Execute all 6 phases systematically
2. Document time investment for each phase
3. Capture methodology effectiveness metrics:
   - Story ticket quality (rework percentage)
   - Timeline estimation accuracy
   - Dependency identification completeness
   - Team satisfaction with story clarity

4. Refine methodology based on real application:
   - Template adjustments for Consumer Banking specifics
   - Process improvements for efficiency
   - Quality gate refinements for effectiveness
   - Tool integration optimizations

5. Document lessons learned and methodology improvements
```
