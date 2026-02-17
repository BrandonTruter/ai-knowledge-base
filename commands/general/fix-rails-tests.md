Rails Test Failure Resolution Framework

Context-Aware Diagnostic Protocol

You are a senior Rails test engineer analyzing test failures in a production-grade codebase. Your analysis must account for Rails-specific patterns, gem ecosystem considerations, and CI/CD integration requirements.

Required Information Matrix

# 1. Error Context Package

```
error_messages:
- Full RSpec/Minitest output with --format documentation
- Stack trace with source file line numbers
- Rails server logs during test execution
- SQL query logs (if database-related)
- Deprecation warnings from Rails/gems

technical_environment:
- rails_version: "7.x or 6.x"
- ruby_version: "3.x"
- test_framework: "RSpec/Minitest/Cucumber"
- database: "PostgreSQL/MySQL/SQLite"
- ci_environment: "GitHub Actions/CircleCI/Jenkins"
- parallelization: "enabled/disabled"
```

**2. Test Artifact Collection**
- Complete spec file with `describe`/`context`/`it` blocks
- Factory definitions (FactoryBot) or fixtures
- Test helpers, shared examples, or custom matchers
- `rails_helper.rb`/`spec_helper.rb` configuration
- Database cleaner strategy and transaction settings
- VCR cassettes or webmock stubs (if applicable)

**3. Implementation Context**
- Model/Controller/Service under test with full file content
- Associated migrations showing schema evolution
- Relevant callbacks, validations, and associations
- Background job definitions (Sidekiq/Delayed Job)
- API serializers or view templates (if integration tests)

**4. Rails-Specific Environmental Factors**
- Test database schema currency (`rake db:test:prepare` status)
- Spring/Bootsnap caching conflicts
- Asset pipeline compilation state (for system tests)
- Zeitwerk autoloading edge cases
- ActiveSupport time zone or date manipulation

**5. Business Requirements Documentation**
- User story or acceptance criteria
- API contract specifications (OpenAPI/JSON Schema)
- State machine diagrams (if using AASM/Statesman)
- Authorization matrix (Pundit/CanCanCan policies)

---

### Multi-Tier Analysis Framework

#### Tier 1: Error Taxonomy & Root Cause Mapping

**Error Classification Decision Tree:**
```
Assertion Failure
├─ Expected vs Actual Mismatch → Logic/Specification Gap
├─ Nil/Undefined Object → Factory/Setup Issue  
└─ Type Coercion Error → Schema/Migration Mismatch

Runtime Exception
├─ NoMethodError → Missing associations/callbacks
├─ ActiveRecord::RecordInvalid → Validation rule change
├─ Timeout/Deadlock → Database transaction isolation level
└─ LoadError → Missing gem or circular dependency

Intermittent Failure (Flaky Test)
├─ Order-dependent → Database cleaner strategy
├─ Time-dependent → Timecop/travel_to missing
├─ Network-dependent → VCR cassette missing/outdated
└─ Parallel execution → Shared resource conflict
```

**Rails-Specific Root Cause Patterns:**

- **Factory Trait Conflicts**: Overlapping trait definitions creating invalid state combinations
- **Callback Chain Violations**: After-commit callbacks not firing in transactional tests
- **Query Interface Changes**: Rails version upgrade breaking `.where()` syntax or scope chaining
- **Timezone Conversion Issues**: `Time.now` vs `Time.current` in date comparisons
- **Counter Cache Desync**: Stale counter_cache values after direct SQL updates

#### Tier 2: Solution Decision Matrix with Rails Heuristics

**Modify Test When:**

| Indicator | Rails-Specific Example | Priority |
|-----------|------------------------|----------|
| Test couples to implementation details | Asserting on ActiveRecord query generation instead of result set | High |
| Test uses deprecated Rails syntax | `assigns(:variable)` in controller specs (Rails 5+) | High |
| Test lacks proper factory setup | Missing `create(:user)` before testing association | Medium |
| Test timing assumptions invalid | Using `sleep()` instead of `perform_enqueued_jobs` | High |
| Test environment mismatch | Expecting production caching behavior in test env | Medium |

**Modify Code When:**

| Indicator | Rails-Specific Example | Priority |
|-----------|------------------------|----------|
| Violates Rails conventions | Not following RESTful routing patterns | High |
| Breaks ActiveRecord contracts | Custom finder returning array instead of relation | High |
| Callback ordering issues | Dependent destroy happening after instead of before | Critical |
| N+1 query in tested code path | Missing `includes()` for association preloading | High |
| State machine logic error | Invalid state transition allowed in model | Critical |

**Rails Version Migration Considerations:**

If test failure appeared after Rails upgrade:
- Check CHANGELOG for breaking changes in tested modules
- Verify gem compatibility matrix (Bundler resolution conflicts)
- Review `config/application.rb` for new framework defaults
- Validate database adapter behavior changes (especially PostgreSQL JSON)

---

### Solution Specification Protocol

#### Required Deliverable Structure

**1. Root Cause Analysis (150-200 words)**

Template:
```
The test failure originates from [specific technical cause] which manifests 
when [triggering condition]. This occurs because [Rails framework behavior] 
combined with [application-specific implementation]. 

Evidence supporting this diagnosis:
- [Stack trace insight]
- [Database log pattern]
- [Comparative behavior in passing vs failing scenario]

The underlying issue represents [logic error | environment mismatch | 
specification gap] with [narrow | moderate | broad] blast radius affecting 
[specific feature area].

Rails-specific factors contributing to this failure:
[ActiveRecord behavior | Callback timing | Asset pipeline | etc.]
```

# 2. Primary Solution Implementation

```
# File: spec/models/user_spec.rb
# Lines: 45-52

# BEFORE (Failing)
it "validates user email uniqueness" do
  user = create(:user, email: "test@example.com")
  duplicate = build(:user, email: "TEST@EXAMPLE.COM")
  expect(duplicate).to be_valid  # Fails: case-sensitive comparison
end

# AFTER (Fixed)
it "validates user email uniqueness case-insensitively" do
  user = create(:user, email: "test@example.com")
  duplicate = build(:user, email: "TEST@EXAMPLE.COM")
  expect(duplicate).not_to be_valid
  expect(duplicate.errors[:email]).to include("has already been taken")
end

# Corresponding Model Change (if needed)
# File: app/models/user.rb
# Add: validates :email, uniqueness: { case_sensitive: false }

Rationale Breakdown:

Root Cause: Test expected case-insensitive validation but model used default case-sensitive uniqueness check
Optimal Approach: Fix test to match actual requirement after confirming business rule with product team; update model validation if case-insensitivity is required
Risk Assessment: Low risk—isolated to user model, covered by existing authentication integration tests
Rails Convention Alignment: Using :case_sensitive option follows ActiveRecord validation best practices
```

# 3. Validation Protocol

```
# Step 1: Verify isolated fix
bundle exec rspec spec/models/user_spec.rb:45 --format documentation

# Step 2: Check for regression across user specs
bundle exec rspec spec/models/user_spec.rb

# Step 3: Validate integration scenarios
bundle exec rspec spec/requests/auth_spec.rb spec/features/registration_spec.rb

# Step 4: Database constraint verification
rails dbconsole
> SELECT * FROM users WHERE LOWER(email) = 'test@example.com';
> \d users  -- Check for unique index definition

# Step 5: Parallel execution safety
bundle exec rspec --order random --seed 1234
```

# 4. Regression Prevention Strategy

New Test Cases to Add:
```
context "email uniqueness edge cases" do
  it "prevents duplicate emails with different casing"
  it "handles email validation with leading/trailing whitespace"
  it "validates uniqueness within organization scope (if multi-tenant)"
  it "handles database-level constraint violations gracefully"
end
```

# 5. Monitoring & Observability

```
# Add to config/initializers/validation_instrumentation.rb
ActiveSupport::Notifications.subscribe("validation.active_record") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  if event.payload[:errors]&.key?(:email)
    Rails.logger.info "Email validation failure: #{event.payload.inspect}"
  end
end
```

Alternative Approach Analysis

Option B: Database-Level Enforcement

ruby# Migration
class AddUniqueIndexToUsersEmail < ActiveRecord::Migration[7.0]
  def change
    remove_index :users, :email if index_exists?(:users, :email)
    execute "CREATE UNIQUE INDEX index_users_on_lowercase_email ON users (LOWER(email))"
  end
end

# Model update
validates :email, uniqueness: { case_sensitive: false }, 
                  format: { with: URI::MailTo::EMAIL_REGEXP }
before_validation :normalize_email

private

def normalize_email
  self.email = email.to_s.downcase.strip
end

Trade-off Analysis:

Option A: Model Validation Only
Pros:
- Simple, portable
- Race condition possible
Cons:
- Low
- Database unique index
- Enforces at DB level
- Migration complexity
- Medium
- Combined (recommended)
- Defense in depth
- Slight redundancy
- Medium
Priority Assignment: HIGH

Option B: Database-Level Enforcement
Pros:
- High
- Enforces at DB level
- Migration complexity
- Low
Cons:
- Complex
- Not portable
- Race condition possible
Priority Assignment: HIGH

Option C: Combined Approach
Pros:
- High
- Enforces at DB level
- Migration complexity
- Low
Cons:
- Complex
- Not portable
- Race condition possible
Priority Assignment: HIGH

Option D: Combined Approach with Database-Level Enforcement
Pros:
- High
- Enforces at DB level
- Migration complexity
- Low
Cons:
- Complex
- Not portable
- Race condition possible
Priority Assignment: HIGH

Option E: Combined Approach with Database-Level Enforcement and API-Level Validation
Pros:
- High
- Enforces at DB level
- Migration complexity
- Low
Cons:
- Complex
- Not portable
- Race condition possible
Priority Assignment: HIGH
