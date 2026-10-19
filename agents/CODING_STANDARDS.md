# Coding standards

These rules apply to all code. Area-specific rules live in [`standards/`](standards/).

## Priorities

- Solve the user's problem, not the code's. Software exists to save someone time; ship working software over elegant software.
- Treat every line as a liability. Prefer deleting code to adding it, and prefer the smaller diff when two changes do the same job.
- Treat complexity as the main enemy. Complexity is anything that makes a system hard to understand and modify. Reject changes that add it without a stated need.
- Measure before you optimise. Bottlenecks occur in surprising places; profile or instrument first, then tune only the part that dominates.
- Keep the feedback loop fast. Make the edit-run-test loop take seconds, and flag any change that slows the build or test suite.

## Writing code

- Write unclever code. Choose the most obvious construct that works; clear and boring beats short and smart.
- Choose data structures first. With the right data structures, the algorithm is usually obvious.
- Use simple algorithms. n is usually small; reach for a fancy algorithm only after measurement shows n is large.
- Use guard clauses. Handle invalid cases first and return early, so the happy path stays unindented at the end of the function.
- Name functions with precise verbs that describe the return value, for example `validationErrors = validateUser(user)`, not `checkUser(user)`.
- Make a function do only what its name and signature say. A reader must not need the body to know its effects.
- Name constants. Do not leave magic numbers or strings inline.
- Treat names as iterative. Rename once the domain concept becomes clearer.
- Prefer pure functions. Do not mutate arguments, monkey patch, or rely on implicit call ordering.
- Use `reduce` only to reduce to a simple value. Use a loop or `map`/`filter` for anything else.
- Prefer static types. Use them to make illegal states unrepresentable: discriminated unions over flags, options over `null`, and branded or wrapper types for constrained values such as IDs and tokens.
- Store and compute time in UTC. Convert to local time only for display.
- Follow the framework's conventions. Hand-rolled patterns become a private framework that the next engineer has to learn.
- Keep formatting and lint rules in config, enforced in CI. Do not hand-format.
- Document why, not how. Comment only on non-obvious algorithms or surprising behaviour.

## Design

- Design for the requirements you know. Break ties between options by compatibility with likely future requirements, and keep the design simple enough to change.
- Define the interface and the boundary before the internals. Shape a module's contract around what consumers need, not around your immediate use.
- Hide implementation behind the interface. A consumer must be able to use a module without reading its internals. Prefer few, deep modules over many shallow ones.
- Assume every observable behaviour of a public interface has a dependant, documented or not (Hyrum's Law). Treat changes to observable behaviour as breaking.
- Keep coupling low and cohesion high. Put code that changes together in one place. Give each module one reason to change: one group of stakeholders.
- Follow the principle of least astonishment.
- Use Functional Core, Imperative Shell. Keep decisions in pure functions that take and return values; push I/O, time, and randomness to a thin shell.
- Validate at I/O boundaries only. Once data passes the edge, trust its type and do not add defensive checks in the core.
- Avoid hasty abstractions. Tolerate duplication until the shared shape is clear; duplication is cheaper than the wrong abstraction.
- Prefer composition. Use inheritance only when you need to instantiate both parent and child and pass either to the same functions.
- Do not add dependency injection containers unless the framework requires them. Inject a dependency only when the design needs the seam, not to make code mockable.
- Wrap each external system in a gateway that speaks your domain's language. Put an anti-corruption layer between your domain and any foreign model.
- Reach for a named design pattern only when the problem already has its shape.

## Architecture

- Start with a modular monolith. Prefer libraries to services; split out a service only when team boundaries require independent deployment.
- Use one computer before N. Know the target load before you design for scale, and assume a single well-indexed database handles far more than the current load.
- Keep processes stateless and share-nothing. Do not keep session or cross-request state in memory or on local disk; persist it to a backing service. This holds on one computer too, so you can restart or add a second instance ([12factor VI](https://12factor.net/processes)).
- Make processes disposable. Start fast. On `SIGTERM`, stop accepting work, finish or return in-flight work within a deadline, then exit. Make jobs safe to rerun if killed midway ([12factor IX](https://12factor.net/disposability)).
- Choose boring technology. Each new or unfamiliar technology spends an innovation token; justify every one. Prefer fewer dependencies: each one is a system to run, monitor, upgrade, and patch.
- Use ports and adapters. Keep domain logic independent of transports, frameworks, and storage.
- Separate presentation, domain, and data access. Keep business rules out of route handlers, controllers, and ORM models.
- Build the "probably are gonna need it" basics from the start: CI with a test framework, automated deploys, API pagination, audit trails, role-based access instead of an `isAdmin` flag, a kill switch, and admin tooling built alongside the feature.
- Load config from the environment. Validate required settings with a schema at startup and fail fast if any are missing. Do not hardcode secrets.
- Treat databases, caches, queues, mail, and object stores as attached resources located by config, such as a URL and credentials. Swapping a local one for a managed one needs no code change ([12factor IV](https://12factor.net/backing-services)).
- Assume breach. Minimise dependencies, automate patching, and limit the blast radius of any one component.
- Write a short design doc before large or cross-team work: context, assumptions, prioritised project values, options with trade-offs, and the decision. If you cannot write it down, the design is not clear yet.

## Error handling

- Handle errors in one place at the edge, such as error middleware, instead of in every function.
- Define application error types for expected failures, and carry the cause chain (for example, JavaScript `Error.cause`).
- Give each error two messages: the internal cause for engineers and a safe, user-facing message.
- Do not log an error and then rethrow it. Domain logic returns errors with context; the edge, such as a handler, middleware, or main loop, logs them once. Long-lived components take a logger in their constructor; see `standards/observability.md`.
- Do not leak stack traces or implementation details in responses.
- Fail fast on invalid input with a specific, human-readable message.
- Leave state unchanged when an operation fails. Do the failable step first, mutate state after it succeeds, and release partial resources on the error path (Ghostty `Tabstops.resize`, Zig `errdefer`).
- Assert invariants you can prove, such as preconditions and loop invariants. For conditions you believe but cannot prove, handle the unexpected case with a simple fallback, such as returning an error, instead of an assertion ([SQLite `assert()` use](https://www.sqlite.org/assert.html)).
- Give complex data structures an integrity check, and run it after each mutation in debug and test builds (Ghostty `PageList.assertIntegrity`).
- Write down the environmental assumptions that correctness depends on, such as `fsync` semantics or delivery guarantees ([SQLite atomic commit](https://www.sqlite.org/atomiccommit.html) §2).
- Set explicit resource limits, and alert as usage approaches them, so operators get warning before failure (SQLite memory limits).
- Reject control characters in untrusted input that reaches a shell, terminal, or interpreter (Ghostty `827d5c8`, `cc53940`).
- When a process reloads configuration at runtime, apply it all or nothing. Build and start it in full before you swap it in, and keep the old one running if any step fails (Caddy `caddy.go`).

## Failure under load

- Retry only transient failures. Do not retry 4xx responses other than 408 and 429, and do not retry cancelled calls ([Google SRE, "Addressing Cascading Failures"](https://sre.google/sre-book/addressing-cascading-failures/); langchainjs `libs/langchain-core/src/utils/async_caller.ts`).
- Use exponential backoff with jitter and a bounded number of attempts.
- Honour `Retry-After` up to a ceiling, and fail fast beyond it. Treat an exhausted quota as permanent, not as a rate limit to wait out.
- Classify failures by status code and error code first. Match error messages only as a last resort for third-party APIs that give nothing else.
- Classify each operation as safe to repeat or not. Retry reads on transient errors. Retry writes only when the request provably never reached the server, such as when no connection was available (HTTP method idempotency, [RFC 9110 §9.2.2](https://www.rfc-editor.org/rfc/rfc9110#section-9.2.2); etcd `client/v3/retry.go`).
- Treat an error or timeout on a write as an unknown outcome, not a failure: the write may have been applied. Make writes idempotent, or read before you retry (etcd `tests/robustness/model/types.go`: `MaybeEtcdResponse`).
- Set a finite concurrency limit on calls to any rate-limited or shared dependency. Do not leave it unbounded by default.

## Working as an agent

- Run the existing tests before you change anything.
- Do not open issues or pull requests on third-party projects unless the user asks you to (Ghostty `AGENTS.md`).
- Verify your change works by running it (for example, with `curl` or a script), not only by passing tests. Report what you ran and what happened.
- Understand every line you submit. Code you cannot explain is not done.
- Keep diffs reviewable. If a diff grows past roughly 1,500 lines, stop and split the work into smaller, independent changes.
- When debugging, list several plausible causes, narrow to the most likely one or two, and confirm with evidence before you change code.
- Suggest turning repeated review feedback into a lint rule, type, or CI check rather than a prompt rule.

## Sources

Maintainer reference for future updates, not agent instructions. Rules here are distilled from these; revisit when they change.

- Dylan's software canon: https://dylanferguson.co/software-canon/
- Dylan's engineering notes: the `tech/` folder of his Obsidian vault.
- Codebases studied: SQLite testing docs, Ghostty, langchainjs, Go standard library, Tailscale, pkgsite, wtf, etcd, and Caddy.
- The Twelve-Factor App: https://12factor.net/
