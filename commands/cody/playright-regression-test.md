# Regression Test Suite Generation Specification for nCino AWS Omni-Channel Application

## Primary Objective

Generate a complete Playwright-based regression test suite for the Omni-Channel Application that validates critical user workflows, business logic, and system integrations while maintaining full compatibility with the existing nTAF infrastructure.

## Framework Context

**Existing Test Infrastructure Location:** /tests/cucumber/

**Technology Stack:**
- TypeScript for all test implementation code
- Playwright for browser automation and API testing
- Cucumber for BDD test specification using Gherkin syntax
- nTAF framework conventions and utilities

**Application Architecture:**
- Multi-tenant SaaS deployment model
- Three distinct portal types: consumer portal, business portal, admin portal
- External integrations: Salesforce CRM, OnePassword identity management
- Supported browsers: Chrome 110+, Firefox 110+, Safari 16+, Edge 110+

## Test Coverage Requirements

### Authentication and Authorization Workflows

**SSO Authentication Flow:**
- Initiate SSO login from application landing page
- Redirect to identity provider authentication page
- Complete authentication with valid SSO credentials
- Verify successful redirect to appropriate portal dashboard
- Validate session token persistence across page navigation
- Test SSO logout and session termination

**Standard Login Flow:**
- Submit valid username and password credentials
- Verify successful authentication and portal access
- Test invalid credential rejection with appropriate error messaging
- Validate account lockout after configurable failed attempt threshold
- Test remember-me functionality and session persistence

**Password Reset Flow:**
- Initiate password reset from login page
- Submit registered email address for reset token generation
- Retrieve reset token from test email service integration
- Complete password reset with new credentials meeting complexity requirements
- Verify successful login with newly created password
- Test expired token rejection and error handling

### Core User Journey Validation

**Loan Application Workflow:**
- Navigate to loan application initiation page
- Complete multi-step application form with required borrower information
- Upload required documentation using file upload component
- Submit completed application for processing
- Verify application status updates in user dashboard
- Test application save-as-draft functionality
- Validate field-level validation rules and error messaging
- Test application withdrawal and cancellation flows

**Document Signing Workflow:**
- Access pending documents requiring signature from user dashboard
- Review document content in embedded viewer
- Complete electronic signature process using signature pad component
- Submit signed documents for processing
- Verify document status change to signed in application record
- Test signature rejection and re-signing workflow
- Validate audit trail creation for signature events

**Offers Selection Workflow:**
- View available loan offers in offers dashboard
- Compare offer details including rates, terms, and conditions
- Select preferred offer from available options
- Confirm offer acceptance and proceed to next workflow stage
- Verify offer acceptance recorded in application history
- Test offer expiration handling and notification
- Validate offer comparison tool functionality

### Administrative Function Testing

**User Management Operations:**
- Create new user accounts with role-based permissions
- Modify existing user profiles and permission assignments
- Deactivate and reactivate user accounts
- Reset user passwords through admin interface
- Assign users to organizational units and teams
- Verify user access restrictions based on assigned roles
- Test bulk user import functionality using CSV upload

**Company Configuration Management:**
- Update company profile information and branding elements
- Configure workflow rules and approval hierarchies
- Manage integration settings for external systems
- Set up notification templates and delivery preferences
- Configure security policies and authentication requirements
- Test configuration validation and error prevention
- Verify configuration changes propagate to all tenant instances

**Test Data Creation Utilities:**
- Generate synthetic loan applications with realistic data
- Create test user accounts across all portal types
- Populate reference data tables with test values
- Generate document sets for signing workflow testing
- Create offer scenarios with varied terms and conditions
- Implement data cleanup procedures for test isolation
- Validate data generation against production data constraints

### API Integration Validation

**Salesforce Data Retrieval:**
- Authenticate to Salesforce API using OAuth 2.0 flow
- Retrieve customer records matching application data
- Sync loan application data to Salesforce opportunity records
- Fetch account information for pre-population workflows
- Validate data mapping between application and Salesforce schemas
- Test error handling for API timeout and failure scenarios
- Verify data synchronization triggers and scheduling

**OnePassword User Management:**
- Create user credentials in OnePassword vault
- Retrieve stored credentials for automated login testing
- Update password records following reset operations
- Delete credentials for deactivated user accounts
- Test credential sharing across test automation team
- Validate secure credential storage and retrieval
- Verify integration error handling and fallback mechanisms

## Technical Implementation Standards

### File Organization Structure

```
/tests/cucumber/
├── src/
│   ├── features/
│   │   ├── authentication/
│   │   │   ├── sso-login.feature
│   │   │   ├── standard-login.feature
│   │   │   └── password-reset.feature
│   │   ├── user-journeys/
│   │   │   ├── loan-application.feature
│   │   │   ├── document-signing.feature
│   │   │   └── offers-selection.feature
│   │   ├── admin/
│   │   │   ├── user-management.feature
│   │   │   ├── company-configuration.feature
│   │   │   └── test-data-creation.feature
│   │   └── integrations/
│   │       ├── salesforce-integration.feature
│   │       └── onepassword-integration.feature
│   ├── support/
│   │   ├── pages/
│   │   │   ├── authentication/
│   │   │   ├── user-portal/
│   │   │   ├── admin-portal/
│   │   │   └── common/
│   │   ├── steps/
│   │   │   ├── authentication-steps.ts
│   │   │   ├── loan-application-steps.ts
│   │   │   ├── document-signing-steps.ts
│   │   │   ├── admin-steps.ts
│   │   │   └── integration-steps.ts
│   │   └── utilities/
│   │       ├── test-data-generator.ts
│   │       ├── api-client.ts
│   │       └── browser-helpers.ts
│   └── config/
│       ├── environments.ts
│       └── browser-config.ts
```

### Naming Convention Standards

**Feature Files:** Use kebab-case with descriptive workflow names
- Pattern: `{workflow-name}.feature`
- Example: `loan-application.feature`, `sso-login.feature`

**Page Object Classes:** Use PascalCase with Page suffix
- Pattern: `{ComponentName}Page.ts`
- Example: `LoginPage.ts`, `LoanApplicationPage.ts`

**Step Definition Files:** Use kebab-case with steps suffix
- Pattern: `{workflow-name}-steps.ts`
- Example: `authentication-steps.ts`, `loan-application-steps.ts`

**Utility Classes:** Use kebab-case describing utility purpose
- Pattern: `{utility-purpose}.ts`
- Example: `test-data-generator.ts`, `api-client.ts`

### Element Selector Strategy

**Primary Selector Approach:** Use data-test-id attributes for all interactive elements

```typescript
// Preferred selector pattern
await page.locator('[data-test-id="login-username-input"]').fill(username);
await page.locator('[data-test-id="submit-application-button"]').click();
```

**Fallback Selector Hierarchy:**
1. data-test-id attributes
2. ARIA labels and roles
3. Semantic HTML elements with unique identifiers
4. CSS selectors with stable class names
5. XPath as last resort for complex DOM navigation

### Page Object Implementation Pattern

```typescript
export class ExamplePage {
  private readonly page: Page;

  // Selector constants
  private readonly selectors = {
    usernameInput: '[data-test-id="username-input"]',
    passwordInput: '[data-test-id="password-input"]',
    submitButton: '[data-test-id="submit-button"]',
    errorMessage: '[data-test-id="error-message"]'
  };

  constructor(page: Page) {
    this.page = page;
  }

  // Action methods with explicit waits
  async enterUsername(username: string): Promise<void> {
    await this.page.waitForSelector(this.selectors.usernameInput, { state: 'visible' });
    await this.page.locator(this.selectors.usernameInput).fill(username);
  }

  // Assertion methods
  async verifyErrorMessage(expectedMessage: string): Promise<void> {
    const errorText = await this.page.locator(this.selectors.errorMessage).textContent();
    expect(errorText).toBe(expectedMessage);
  }
}
```

### Step Definition Implementation Pattern

```typescript
import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';

Given('the user navigates to the login page', async function() {
  await this.page.goto(this.config.baseUrl + '/login');
  await this.loginPage.waitForPageLoad();
});

When('the user enters username {string} and password {string}', async function(username: string, password: string) {
  await this.loginPage.enterUsername(username);
  await this.loginPage.enterPassword(password);
});

Then('the user should see the dashboard', async function() {
  await expect(this.page).toHaveURL(/.*dashboard/);
  await this.dashboardPage.verifyPageLoaded();
});
```

### Wait Strategy Implementation

**Explicit Waits:** Use for all element interactions
```typescript
await page.waitForSelector(selector, { state: 'visible', timeout: 10000 });
```

**Network Idle Waits:** Use after navigation and form submissions
```typescript
await page.waitForLoadState('networkidle', { timeout: 30000 });
```

**Custom Condition Waits:** Use for complex state verification
```typescript
await page.waitForFunction(() => document.querySelector('[data-test-id="status"]')?.textContent === 'Complete');
```

### Error Handling and Retry Mechanisms

**Automatic Retry Configuration:**
```typescript
test.describe.configure({ retries: 2 });
```

**Custom Retry Logic for Flaky Operations:**
```typescript
async performActionWithRetry(action: () => Promise<void>, maxAttempts: number = 3): Promise<void> {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      await action();
      return;
    } catch (error) {
      if (attempt === maxAttempts) throw error;
      await this.page.waitForTimeout(1000 * attempt);
    }
  }
}
```

**Screenshot Capture on Failure:**
```typescript
test.afterEach(async ({ page }, testInfo) => {
  if (testInfo.status !== 'passed') {
    await page.screenshot({
      path: `screenshots/${testInfo.title}-${Date.now()}.png`,
      fullPage: true
    });
  }
});
```

## Test Data Management

### Test Data Generation Requirements

**Synthetic Data Creation:** Generate realistic test data matching production data patterns
- Personal information: names, addresses, phone numbers, email addresses
- Financial data: income amounts, employment history, credit scores
- Loan parameters: amounts, terms, interest rates, product types
- Document metadata: file names, upload timestamps, document types

**Data Isolation Strategy:** Ensure test data does not conflict across parallel test execution
- Use unique identifiers with timestamp and random string components
- Implement test data cleanup in afterEach hooks
- Maintain separate data sets for each test environment

**Test Data Utilities Location:** /tests/cucumber/src/support/utilities/test-data-generator.ts

### Environment-Specific Configuration

**Environment Configuration File:** /tests/cucumber/src/config/environments.ts

```typescript
export interface EnvironmentConfig {
  name: string;
  baseUrl: string;
  apiBaseUrl: string;
  salesforceUrl: string;
  onePasswordVault: string;
  defaultTimeout: number;
  retryAttempts: number;
}

export const environments: Record<string, EnvironmentConfig> = {
  dev: { /* configuration */ },
  qa: { /* configuration */ },
  staging: { /* configuration */ }
};
```

## Cross-Browser Testing Requirements

### Browser Configuration Matrix

**Chrome Testing:**
- Version: 110 or higher
- Viewport sizes: 1920x1080 (desktop), 1366x768 (laptop)
- Device emulation: None for desktop tests

**Firefox Testing:**
- Version: 110 or higher
- Viewport sizes: 1920x1080 (desktop), 1366x768 (laptop)
- Specific testing: File upload/download functionality

**Safari Testing:**
- Version: 16 or higher
- Viewport sizes: 1920x1080 (desktop)
- Specific testing: Date picker components, modal dialogs

**Edge Testing:**
- Version: 110 or higher
- Viewport sizes: 1920x1080 (desktop)
- Specific testing: PDF viewer integration

### Browser-Specific Test Execution

```typescript
const browsers = ['chromium', 'firefox', 'webkit'];

for (const browserType of browsers) {
  test.describe(`${browserType} tests`, () => {
    test.use({ browserName: browserType });
    // Test implementation
  });
}
```

## Execution and Performance Requirements

### Test Execution Time Constraints

**Maximum Total Execution Time:** 30 minutes for complete regression suite across single browser

**Individual Test Timeout:** 60 seconds per scenario

**Performance Optimization Strategies:**
- Parallel test execution with worker count matching CPU cores
- Shared browser context for related test scenarios
- Efficient test data setup using API calls instead of UI interactions
- Strategic use of beforeAll hooks for expensive setup operations

### Parallel Execution Configuration

```typescript
export default defineConfig({
  workers: process.env.CI ? 4 : 2,
  fullyParallel: true,
  timeout: 60000,
  expect: { timeout: 10000 }
});
```

## Quality Assurance Standards

### Test Stability Requirements

**Zero False Positives Target:** Tests must produce consistent results across 10 consecutive executions in stable environment

**Flaky Test Identification:** Flag tests with success rate below 95% for investigation and remediation

**Stability Improvement Techniques:**
- Implement robust wait strategies avoiding fixed timeouts
- Use state-based assertions instead of time-based waits
- Isolate test data to prevent cross-test contamination
- Reset application state between test scenarios

### Code Quality Standards

**TypeScript Strict Mode:** Enable strict type checking for all test code

**Linting Requirements:** Pass ESLint validation with nTAF configuration

**Code Review Checklist:**
- Page objects follow single responsibility principle
- Step definitions contain no business logic
- Selectors use data-test-id attributes
- Error messages provide actionable debugging information
- Comments explain complex logic and workarounds

## Integration with Existing Infrastructure

### nTAF Framework Compatibility

**Required Imports from Existing Utilities:**
- Authentication helpers from /tests/cucumber/src/support/utilities/
- API client wrappers for external service integration
- Custom assertion libraries for business rule validation
- Logging and reporting utilities

**Framework Convention Adherence:**
- Use existing World object for shared test context
- Follow established hook patterns for setup and teardown
- Integrate with existing reporting mechanisms
- Maintain compatibility with current CI/CD pipeline configuration

### CI/CD Pipeline Integration

**Pipeline Execution Triggers:**
- Automated execution on pull request creation
- Scheduled nightly regression runs
- Manual execution via pipeline dispatch

**Test Result Reporting:**
- Generate Cucumber JSON reports for dashboard integration
- Produce HTML reports with screenshots for failed tests
- Export JUnit XML for CI system integration
- Publish test coverage metrics to monitoring dashboard

**Artifact Retention:**
- Store test execution videos for failed scenarios
- Preserve screenshots with timestamp and test context
- Archive test logs with debug-level information
- Maintain test data snapshots for failure investigation

## Deliverable Specifications

### Required File Deliverables

**Feature Files:** Complete Gherkin specifications for all test scenarios
- Location: /tests/cucumber/src/features/
- Format: .feature files with Given-When-Then syntax
- Content: Business-readable scenario descriptions with data tables and examples

**Step Definition Files:** TypeScript implementation of all feature steps
- Location: /tests/cucumber/src/support/steps/
- Format: .ts files with Cucumber step decorators
- Content: Step implementations delegating to page objects

**Page Object Files:** TypeScript classes representing application pages and components
- Location: /tests/cucumber/src/support/pages/
- Format: .ts files with class-based page object pattern
- Content: Element selectors, action methods, assertion methods

**Utility Files:** Helper functions and shared test infrastructure
- Location: /tests/cucumber/src/support/utilities/
- Format: .ts files with exported functions and classes
- Content: Test data generators, API clients, browser helpers

**Configuration Files:** Environment and execution configuration
- Location: /tests/cucumber/src/config/
- Format: .ts files with exported configuration objects
- Content: Environment URLs, timeouts, browser settings

### Documentation Deliverables

**README Updates:** Comprehensive documentation additions to existing README.md
- Test suite overview and coverage summary
- Setup instructions for local test execution
- Environment configuration guide
- Troubleshooting common issues

**Inline Code Comments:** Explanatory comments for complex logic
- Business rule explanations in step definitions
- Workaround documentation for known issues
- Performance optimization notes
- Browser-specific handling explanations

**Test Coverage Report:** Detailed mapping of tests to application features
- Feature-to-test traceability matrix
- Coverage gaps and future test recommendations
- Risk assessment for untested functionality

**Maintenance Guide:** Instructions for ongoing test suite maintenance
- Adding new test scenarios process
- Updating page objects for UI changes
- Managing test data and environment configuration
- Debugging failed tests and analyzing results

## Success Validation Criteria

### Functional Success Metrics

**Test Execution Success Rate:** 100% pass rate in stable test environment with valid test data

**Cross-Browser Compatibility:** All tests execute successfully on Chrome, Firefox, Safari, and Edge without browser-specific modifications

**Coverage Completeness:** All specified workflows have corresponding automated test scenarios

**Integration Verification:** Tests successfully interact with existing nTAF utilities and framework components

### Performance Success Metrics

**Execution Time Compliance:** Full regression suite completes within 30-minute threshold on standard CI infrastructure

**Resource Utilization:** Test execution consumes less than 4GB memory per worker process

**Parallel Execution Efficiency:** Tests execute successfully with worker count up to 8 without race conditions

### Quality Success Metrics

**Code Quality Compliance:** All test code passes TypeScript compilation and ESLint validation

**Maintainability Score:** Page objects average fewer than 200 lines of code per class

**Documentation Completeness:** All public methods include JSDoc comments with parameter descriptions

**Test Isolation:** Tests execute successfully in random order without dependencies

Execute test suite generation following these specifications, ensuring all deliverables meet defined quality standards and integration requirements.
