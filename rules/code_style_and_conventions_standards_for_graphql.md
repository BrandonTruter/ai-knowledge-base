# Code Style and Conventions Standards for GraphQL

> From [CodingRules.ai](https://codingrules.ai/rules/code-style-and-conventions-standards-for-graphql)

**Tags:** GraphQL

---

# Code Style and Conventions Standards for GraphQL

This document outlines the code style and conventions that all GraphQL code must adhere to. The goal is to ensure consistency, readability, and maintainability across all GraphQL schemas, resolvers, and related code. These standards apply to both the schema definition language (SDL) and the code implementing the GraphQL API (typically in languages such as JavaScript/TypeScript).

## 1. Formatting and Style

### 1.1 Schema Definition Language (SDL)

*   **Do This:** Use a consistent indentation style (2 spaces or 4 spaces, *consistently* applied). Prefer 2 spaces for better horizontal readability.
*   **Don't Do This:** Mix tabs and spaces. Use inconsistent indentation.

**Why:** Consistent indentation improves readability and reduces visual noise.

**Example (Good - 2 spaces):**

"""graphql
type User {
  id: ID!
  name: String!
  email: String
  posts: [Post!]!
}
"""

**Example (Bad - Inconsistent):**

"""graphql
type User {
	id: ID!
    name: String!
  email: String
  posts: [Post!]!
}
"""

*   **Do This:** Use blank lines to separate logically distinct sections of the schema (e.g., different types, queries, mutations).
*   **Don't Do This:** Write long, unbroken sections of schema without logical breaks.

**Why:** Improves readability by visually separating concerns.

**Example (Good):**

"""graphql
