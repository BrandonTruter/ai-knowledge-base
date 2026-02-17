When providing Rails code examples, include robust error handling that addresses:
1. Database failures (connection issues, constraint violations)
2. External service failures (timeouts, bad responses)
3. Invalid user input
4. Edge cases specific to the business logic

For each type of failure, show both the handling code and how errors should be communicated to users or logged for debugging. Emphasize graceful degradation and maintaining system integrity.