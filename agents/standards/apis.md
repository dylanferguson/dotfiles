# APIs

## Design

- Prefer familiar patterns over clever ones. A user must be able to guess how an endpoint works before reading the docs.
- Fix the resource model first. An API exposes the data model that a UI can hide.
- Never break existing clients. Add fields freely; do not remove, retype, or restructure them. Assume clients depend on every observable behaviour, including undocumented ones.
- Version only as a last resort.
- Keep reads and writes as separate operations.
- Make expensive fields opt-in, through an `include_x` parameter or an `includes` array.
- Use cursor-based pagination for any list that can grow, and return a `next_page` value so clients do not compute cursors.
- Accept an optional idempotency key on requests that take action, so clients can retry safely after a timeout or 5xx.
- Rate limit every endpoint, and limit expensive operations harder. Return `Retry-After` and remaining-limit headers.
- Keep a kill switch for every public API.
- Support long-lived, prefixed API keys. Offer OAuth as an option, not a requirement.
- Return a unique request ID on every response.
- Do not return `200` with an error body. Do not silently truncate input or output.
- Use JSON bodies, not form encoding.
- Avoid GraphQL unless the use case needs it.
- For internal APIs, relax these rules except idempotency and rate limits.

## Validation

- Validate structure at the edge, in middleware, and fail fast. Validate business rules in the domain layer.
- Validate strictly. Reject malformed input with a detailed, human-readable message; do not follow Postel's Law.
- Define boundary types as JSON Schema in the OpenAPI document. Generate types from the schema and validate at runtime against the same schema.
- Do not validate email addresses with a complex regex. Check for an `@`, then confirm ownership with a verification message.

## Errors

- Return errors as Problem Details (RFC 7807, `application/problem+json`) with `type`, `title`, `status`, and, where useful, `detail` and `instance`.
- Do not expose stack traces or internal details in error responses.

## Documentation

- Document every API with OpenAPI, and AsyncAPI for events. Serve generated docs from the service.

## When it applies

Follow these only when the trigger matches.

- When several clients can update the same resource, return an `ETag` and require `If-Match` on updates; respond 412 on mismatch ([RFC 9110 §13.1.1](https://www.rfc-editor.org/rfc/rfc9110#section-13.1.1)).
