# Testing

## What to test

- Test to the level of confidence you need, no further. Skip tests for kinds of mistakes you do not make. Do not chase 100% coverage.
- Test behaviour through the public interface: the HTTP API for a service, the UI for a UI, the exports for a module. Do not test private functions or internal structure.
- If a test would still pass when the product breaks in production, do not write it.
- Do not write change-detector or tautological tests: tests that restate the implementation, assert on mocks you configured, or fail on any refactor.
- Do not assert on log output. Logs are implementation details.
- Verify side effects that users see, such as outgoing email or webhooks.
- Cover edge cases with ZOMBIE: zero, one, many, boundaries, interfaces, and exceptions.
- Delete tests that no longer add confidence, including scaffolding tests you wrote to explore an implementation.

## Levels

- Make integration tests the main suite. Exercise the real code path from request to storage and back.
- Mock only at the outermost boundary, such as the network, and only for systems you do not control. Do not mock internals, private functions, or your own adapters.
- Use mocked external dependencies to simulate failures you cannot trigger for real, such as timeouts and 5xx responses. Add contract tests to catch drift between the mock and the real API.
- Use real databases and file systems in tests when each test can get a clean, isolated, fast instance. Otherwise use an in-memory equivalent that resets per test.
- Keep browser-driven end-to-end tests to a few smoke tests of critical flows. Test UI behaviour inside the framework, for example with Testing Library.
- For untested legacy code, add integration tests for the most important and most frequently changed features first. Add unit tests only to code you touch.

## Failure paths

Most bugs hide in error handling that tests never reach.

- Test error paths by injecting faults at the boundary: wrap the allocator, file system, or dependency client so a test can make the Nth call fail. Loop N from 1 until the operation completes without hitting the fault ([SQLite OOM and I/O tests](https://www.sqlite.org/testing.html#anomaly_testing); Ghostty `src/tripwire.zig`, `"PageList init error"` in `src/terminal/PageList.zig`).
- Run each fault loop twice: once where the fault happens once and the dependency recovers, and once where it keeps failing.
- After every injected fault, assert that no resources leaked and that state is either unchanged or fully applied, never partial (SQLite crash tests; Ghostty `"Tabstops: resize alloc failure preserves state"`).
- Test compound failures, such as a fault during recovery from an earlier fault.
- Detect leaks on every test run, not in a separate job (SQLite §6; Zig `std.testing.allocator`).
- Test both sides of every documented limit, and one step past it to confirm the error.
- Fuzz parsers and anything that reads untrusted input. Commit the inputs that found bugs as a corpus, and replay it in the normal suite (SQLite `fuzzcheck`; Ghostty `test/fuzz-libghostty/corpus`).
- When code has a fast path and a slow path, or an optional optimisation, assert that both produce the same output (SQLite §9; Ghostty `fuzz-stream` picks the SIMD or scalar path from the first input byte).
- Test the build you ship, with release settings, not only a debug build ([TH3](https://www.sqlite.org/th3.html): "test what you fly").
- Pair each fault point with a trigger that drives the code to it, such as a compaction or a snapshot. A fault on a path the traffic never reaches proves nothing (`etcd/tests/robustness/failpoint/gofail.go`).
- For anything with consistency guarantees, record every client operation and its result while you inject crashes and partitions, then check the history against a simple model of the API with a linearizability checker (`etcd/tests/robustness/`, porcupine).
- Keep a table of the bugs that fault testing found, each with a command that reproduces it. Rerun them all before and after you change the test framework, so it never loses the ability to catch them (`etcd/tests/robustness/README.md`).
- Put expensive invariant checks behind a flag that every test run enables and production leaves off (`etcd/client/pkg/verify/`, `ETCD_VERIFY=all` in `scripts/test.sh`).

## Structure

- Make the unit of isolation the test, not the class. Each test must pass alone, in any order, and in parallel. Do not share mutable fixtures.
- Write DAMP tests. Prefer a readable, self-contained test over a DRY one.
- Follow arrange, act, assert. Move setup that distracts from the assertion into named helpers.
- Name tests after the behaviour they specify, for example `rejects checkout when cart is empty`.
- Write scenario tests once against a small cluster or client interface, and run the same suite in-process and against the real binary, chosen by build tag (`etcd/tests/framework/interfaces/`, `tests/common/integration_test.go`, `tests/common/e2e_test.go`).
- Test upgrades, downgrades, and mixed-version deployments for anything that persists data or talks to other versions (`etcd/tests/e2e/etcd_mix_versions_test.go`, `cluster_downgrade_test.go`).

## Process

- Use TDD for bug fixes: write a regression test, confirm it fails for the expected reason, fix, then run the relevant tests. Do not require TDD for feature work.
- Do not weaken or delete a failing test to make it pass.
- Fix flaky tests immediately. Allow two or three retries only in end-to-end tests, for network blips, and report retried tests as flaky.
- Make the whole suite run locally with one command, hermetically, in minutes. Flag changes that slow it down.
- Keep a fast subset that runs before every commit, and run slow fault, fuzz, and soak tests in CI (SQLite "veryquick").
- While iterating, run the tests for the area you changed. Run the full suite before you open a pull request (Ghostty `AGENTS.md`).
- For behaviour you cannot automate, keep a written manual checklist in the repository and run it when you touch that area (Ghostty `HACKING.md` "Input Stack Testing"; SQLite release checklists).
