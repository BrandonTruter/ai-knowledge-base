---

description: Ruby Best Practices
---
# Ruby Style Guide

**Testing and Code Coverage**

- Write tests for all new code. No code changes should be accepted without corresponding test coverage. Prefer writing tests first using Test Driven Development (TDD).
- Mock all external API calls in tests. Never allow tests to make real network requests.
- Improve coverage when modifying existing code, especially for files with low coverage (e.g., `data_fetcher.rb`, `github_client.rb`, `html_generator.rb`).
- Always run the coverage report (`bundle exec rake coverage`) to verify the impact of your changes.
- Place test files in the `test/` directory, use a `_test.rb` suffix, and require `test_helper` at the top.
- Follow the `test_method_name` pattern for test methods.
- Use Mocha’s `mock` and `stubs` for external dependencies.
- Use `setup` and `teardown` for test preparation and cleanup.
- Store fixtures in `test/fixtures/`.
- Add an empty line before each assertion method to comply with RuboCop’s Minitest/EmptyLineBeforeAssertionMethods rule and improve readability.
- Limit test methods to no more than 5 assertions. Split tests as needed and ensure each has independent setup.

**Method Design and Complexity**

- Each method should have a single, clear responsibility. If a method’s purpose requires “and” to describe, split it.
- Keep methods under 20 lines (excluding comments). Cyclomatic complexity should be under 7; perceived complexity under 8. Extract helper methods as needed.
- Use descriptive method names. Break lines longer than 100 characters using line continuation with `\`.
- Use guard clauses and early returns for edge cases.
- Extract validation, data transformation, and complex conditionals into dedicated, well-named helper methods.
- Always test newly extracted methods. If helpers are private, consider testable delegation in test environments.

**Ruby Style and RuboCop Compliance**

- Use 2 spaces for indentation, never tabs.
- Keep lines under 100 characters.
- Use spaces around operators, after commas, colons, and semicolons. No trailing whitespace at line ends or on blank lines.
- End each file with a newline.
- Use `snake_case` for variables, methods, and file names; `CamelCase` for classes/modules; `SCREAMING_SNAKE_CASE` for constants.
- Use single quotes for non-interpolated strings, double quotes for interpolated or special-character strings.
- Add `# frozen_string_literal: true` at the top of every file.
- Prefer early returns for error and edge cases.
- Use visibility modifiers (`private`, `protected`) to encapsulate implementation details.
- Group related methods together within classes/modules.
- Add comments for complex or non-obvious code. Document public methods, parameters, and return values.
- Rescue only specific exceptions, not `Exception` or bare `rescue`. Use descriptive messages for exceptions and log them appropriately.

**Common RuboCop Offenses and Fixes**

- Watch for and remove trailing whitespace, especially on blank