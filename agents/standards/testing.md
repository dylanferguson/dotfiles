# Testing

## What to test

- Test to the level of confidence you need, no further. Skip tests for kinds
  of mistakes you do not make. Do not chase 100% coverage.
- Test behaviour through the public interface: the HTTP API for a service, the
  UI for a UI, the exports for a module. Do not test private functions or
  internal structure.
- If a test would still pass when the product breaks in production, do not
  write it.
- Do not write change-detector or tautological tests: tests that restate the
  implementation, assert on mocks you configured, or fail on any refactor.
- Do not assert on log output. Logs are implementation details.
- Verify side effects that users see, such as outgoing email or webhooks.
- Cover edge cases with ZOMBIE: zero, one, many, boundaries, interfaces, and
  exceptions.
- Delete tests that no longer add confidence, including scaffolding tests you
  wrote to explore an implementation.

## Levels

- Make integration tests the main suite. Exercise the real code path from
  request to storage and back.
- Mock only at the outermost boundary, such as the network, and only for
  systems you do not control. Do not mock internals, private functions, or
  your own adapters.
- Use mocked external dependencies to simulate failures you cannot trigger
  for real, such as timeouts and 5xx responses. Add contract tests to catch
  drift between the mock and the real API.
- Use real databases and file systems in tests when each test can get a
  clean, isolated, fast instance. Otherwise use an in-memory equivalent that
  resets per test.
- Keep browser-driven end-to-end tests to a few smoke tests of critical
  flows. Test UI behaviour inside the framework, for example with Testing
  Library.
- For untested legacy code, add integration tests for the most important and
  most frequently changed features first. Add unit tests only to code you
  touch.

## Structure

- Make the unit of isolation the test, not the class. Each test must pass
  alone, in any order, and in parallel. Do not share mutable fixtures.
- Write DAMP tests. Prefer a readable, self-contained test over a DRY one.
- Follow arrange, act, assert. Move setup that distracts from the assertion
  into named helpers.
- Name tests after the behaviour they specify, for example
  `rejects checkout when cart is empty`.

## Process

- Use TDD for bug fixes: write a regression test, confirm it fails for the
  expected reason, fix, then run the relevant tests. Do not require TDD for
  feature work.
- Do not weaken or delete a failing test to make it pass.
- Fix flaky tests immediately. Allow two or three retries only in end-to-end
  tests, for network blips, and report retried tests as flaky.
- Make the whole suite run locally with one command, hermetically, in
  minutes. Flag changes that slow it down.
