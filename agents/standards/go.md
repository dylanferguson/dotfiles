# Go

These rules follow [Effective Go](https://go.dev/doc/effective_go), [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments), and the [Google Go style guide](https://google.github.io/styleguide/go/). When this file and Code Review Comments disagree, follow Code Review Comments. Paths point to examples in the Go standard library (`src/` in [golang/go](https://go.googlesource.com/go)), [Tailscale](https://github.com/tailscale/tailscale), [pkgsite](https://github.com/golang/pkgsite), [wtf](https://github.com/benbjohnson/wtf), [etcd](https://github.com/etcd-io/etcd), and [Caddy](https://github.com/caddyserver/caddy).

## Layout

- In applications and services, not libraries, put domain types and service interfaces in the root package, with no external dependencies. Name each subpackage after the dependency it wraps, such as `sqlite` or `http`, and wire them together in `cmd/`. This is Dylan's preference, from his notes and [Ben Johnson, "Packages as layers"](https://www.gobeyond.dev/packages-as-layers/) (`wtf/`), not official Go guidance.
- Keep `main` to one call to `run(ctx, args, getenv, stdin, stdout, stderr) error`. Tests call `run` with their own arguments and environment ([Mat Ryer](https://grafana.com/blog/2024/02/09/how-i-write-http-services-in-go-after-13-years/)).
- Put packages that other modules must not import under `internal/` ([module layout](https://go.dev/doc/modules/layout)).
- Give every package a doc comment ([Code Review Comments](https://go.dev/wiki/CodeReviewComments#package-comments)).
- Do not name packages `util`, `common`, `types`, or `misc`.

## Interfaces

- Define interfaces in the package that consumes them. Return concrete types. Do not add an interface just so you can mock it ([Code Review Comments](https://go.dev/wiki/CodeReviewComments#interfaces)).
- Keep interfaces small, often one method, such as `io.Reader` ("The bigger the interface, the weaker the abstraction", Go Proverbs).
- Assert that a type satisfies an interface at compile time with `var _ I = (*T)(nil)` ([Go FAQ](https://go.dev/doc/faq#guarantee_satisfies_interface); `wtf/mock/dial.go`, `caddy/AGENTS.md`).
- Test time-dependent code with `testing/synctest`, which fakes the clock without injection (`src/testing/synctest/`). Inject a small clock interface only when synctest cannot cover the case (`tailscale/tstime/tstime.go`).

## Errors

- Wrap errors with `fmt.Errorf("doing x: %w", err)`. Check them with `errors.Is` and `errors.As` (or `errors.AsType` on Go 1.26 and later), not `==` or a type assertion (`src/errors/errors.go`).
- Keep a small, closed set of error categories that callers act on, such as not found and invalid argument. Map them to status codes in one function (`pkgsite/internal/derrors/derrors.go`: `ToStatus`; `wtf/error.go`: `ErrorCode`).
- Add context once per function: name the operation and its key arguments, and do not repeat what the wrapped error already says ([Google style guide](https://google.github.io/styleguide/go/best-practices#adding-information-to-errors); `pkgsite/internal/derrors/derrors.go`: `Wrap`).
- Separate what the user sees from what the operator logs. Give the HTTP error a public message and a private cause, and send only the message. Errors without a public message become a bare 500 (`tailscale/tsweb/tsweb.go`: `HTTPError`; `wtf/error.go`).
- Put the request ID in error responses, so a user report leads to the log line (`tsweb.go`: `WriteHTTPError`; `caddy/modules/caddyhttp/errors.go`: `HandlerError`).
- Write error strings in lowercase, without trailing punctuation.
- Do not panic for ordinary errors. Recover panics in one middleware, and turn them into errors with a stack trace (`tsweb.go`: `panic2err`; `pkgsite/internal/middleware/panic.go`).

## Context and cancellation

- Pass `ctx context.Context` as the first parameter. Do not store it in a struct (`src/context/context.go`, package doc).
- Use context values only for request-scoped data, such as the request ID or trace. Do not use them for optional parameters or loggers.
- Call every `CancelFunc`. When the reason matters, record it with `WithCancelCause`.
- Do not count a client disconnect as a server error in logs or error-rate metrics. Nginx and Tailscale record it as 499 (`tsweb.go`: `reqCancelled`).

## Concurrency

- Prefer synchronous APIs. Let callers add goroutines.
- Make every goroutine's exit obvious. In tests, check that none leak (`tailscale/tstest/resource.go`: `ResourceCheck`).
- Comment each mutex with the fields it guards, and suffix methods that need the lock held with `Locked` (`src/database/sql/sql.go`, `src/net/http/transport.go`).
- Run tests with `-race` in CI.

## HTTP servers

- Build one `http.Handler` in `NewServer`, which takes every dependency as an argument. List all routes in one `routes.go`, with each route's middleware next to it (Mat Ryer).
- Write handlers as functions that take their dependencies and return `http.Handler`. Define one-off request and response types inside them.
- Let handlers return an error, and write error responses in one place (`tsweb.go`: `ReturnHandler`; Caddy's `caddyhttp.Handler`).
- Use the standard `http.ServeMux`, which matches methods and path wildcards (`src/net/http/pattern.go`).
- Set `ReadHeaderTimeout`, `ReadTimeout`, `WriteTimeout`, and `IdleTimeout`. A zero value means no timeout (`src/net/http/server.go`). Cap request bodies with `http.MaxBytesReader`.
- Shut down with `Server.Shutdown(ctx)` on a deadline, and treat `http.ErrServerClosed` as success.
- Label request metrics with the route pattern (`Request.Pattern`), not the raw URL.

## Configuration

- Read flags and environment variables only in `run`, through a `flag.FlagSet` and the `getenv` you pass in. Do not use the global `flag` set (Mat Ryer).

## Logging and metrics

- Use `log/slog`. Implement `LogValuer` on types that hold secrets so they redact themselves.
- Give long-lived components, such as servers, clients, stores, and background workers, a `*slog.Logger` in their constructor, and store it. Never use the global default logger or one carried in `context`. Domain logic does not log: it returns wrapped errors, and the handler, middleware, or main loop logs once. Do not pass a logger through ordinary function calls.
- Name metrics `<namespace>_<subsystem>_<name>_<unit>` in base units ([Prometheus naming](https://prometheus.io/docs/practices/naming/); `etcd_disk_wal_fsync_duration_seconds` in `etcd/server/storage/wal/metrics.go`).

## Tests

- Use the standard `testing` package with table-driven subtests and `cmp.Diff`. Do not use assertion libraries ([Google style guide](https://google.github.io/styleguide/go/decisions#assertion-libraries)).
- Report failures as `Foo(%q) = %v, want %v`: function, input, got, then want ([Code Review Comments](https://go.dev/wiki/CodeReviewComments#useful-test-failures)).
- Mark helpers with `t.Helper()`. Use `t.Cleanup`, `t.Context`, `t.TempDir`, and `t.Setenv` instead of hand-written teardown.
- Prefer hand-written fakes, which are working in-memory implementations. Use `httptest.NewServer` for HTTP dependencies. For a stub, write a struct of function fields (`tailscale/tstest/integration/testcontrol/`; `wtf/mock/`). Use generated mocks only at the outermost boundary when a fake is impractical.
- Test the database against the real engine, and give each test or test package its own database so tests stay isolated (`pkgsite/internal/postgres/test_helper.go`; `:memory:` in `wtf/sqlite/sqlite_test.go`).
- Skip tests that need what the machine lacks, with a reason. Do not fail them (`src/internal/testenv/testenv.go`: `MustHaveExternalNetwork`).
- Skip a known-flaky test only with a linked issue (`testenv.SkipFlaky(t, issue)`).
- Run benchmarks briefly in CI so they keep compiling and running, for example `-bench=. -benchtime=1x -run='^$'` (`src/cmd/dist/test.go`; Tailscale `.github/workflows/test.yml`).

## Tooling

- Run `gofmt`, `go vet`, `staticcheck`, and `govulncheck` in CI. Document each disabled check with its reason.
- Pin the Go version with the `toolchain` directive in `go.mod`, and use the same version in CI.

## When it applies

Follow these only when the trigger matches.

### Interfaces that others implement

- Ship a conformance test that any implementation can run (`src/testing/slogtest/`, `src/testing/fstest/`).

### CLIs

- Test with txtar scripts: commands, expected output, and input files in one text file (`src/cmd/go/testdata/script/README`; `rsc.io/script` or `testscript` outside the Go repo).

### Protocols and complex state machines

- Keep the core a deterministic state machine with no I/O, goroutines, or clock. It takes inputs, such as messages and ticks, and returns what to persist and send. The caller does the I/O (`etcd-io/raft/README.md`, `Node.Ready`).
- Test it with data-driven scripts: a file of commands and the expected output for each, rewritten with a flag when behaviour changes on purpose (`etcd-io/raft/interaction_test.go`).

### Plugin hosts and live config reload

- Run each plugin through separate construct, validate, start, and cleanup steps. Keep validation fast, and make cleanup safe after a partial setup (`caddy/modules.go`: `Provisioner`, `Validator`, `CleanerUpper`).
- Reload by building and starting the new config in full, then swapping it in, then stopping the old one. If any step fails, clean up the new config and keep the old one running (`caddy/caddy.go`: `run`, `changeConfig`).
- Share long-lived resources, such as listeners, across reloads through a reference-counted pool, so a reload does not drop connections (`caddy/usagepool.go`).
- If config arrives in several formats, convert each to one canonical format, and golden-test each converter from input to output (`caddy/caddyconfig/configadapters.go`, `caddytest/integration/caddyfile_adapt/`).

### Files that must survive a crash

- Write to a temporary path, `fsync` it, rename it into place, and `fsync` the parent directory (`etcd/server/storage/wal/wal.go`: `Create`; `tailscale/atomicfile/`).
- For append-only logs, checksum every record. On open, truncate a torn tail from an unsynced write rather than refusing to start (`etcd/server/storage/wal/repair.go`).
- Record a histogram for every `fsync`, and warn when one exceeds its budget (`wal.go`: `warnSyncDuration`).
- To test crash recovery, write fault points as comments that only a test build turns into code, so release builds carry no seam (gofail, `etcd/server/etcdserver/raft.go`). See `testing.md`.

### Servers with a public listener

- Serve metrics and debug endpoints on a separate, private listener ([etcd #15402](https://github.com/etcd-io/etcd/issues/15402)).
