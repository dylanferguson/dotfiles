# Go

Paths cite the Go standard library (`src/` in [golang/go](https://go.googlesource.com/go)), [Tailscale](https://github.com/tailscale/tailscale), [pkgsite](https://github.com/golang/pkgsite), and [wtf](https://github.com/benbjohnson/wtf), [etcd](https://github.com/etcd-io/etcd) with [etcd-io/raft](https://github.com/etcd-io/raft), and [Caddy](https://github.com/caddyserver/caddy). These are the reference Go codebases these rules were checked against. When this file and [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments) disagree, follow Code Review Comments.

## Layout

- Put domain types and service interfaces in the root package, with no external dependencies. Name each subpackage after the dependency it wraps, such as `sqlite`, `http`, or `mock`, and wire them together in `cmd/` (`wtf/wtf.go`, `wtf/sqlite/`, `wtf/http/`).
- Keep `main` to one call to `run(ctx, args, getenv, stdin, stdout, stderr) error`. Tests call `run` with their own arguments and environment ([Mat Ryer](https://grafana.com/blog/2024/02/09/how-i-write-http-services-in-go-after-13-years/)).
- Put internal packages under `internal/` (`pkgsite/internal/`).
- Give every package a doc comment. Tailscale fails CI without one (`pkgdoc_test.go`).
- Do not name packages `util`, `common`, `types`, or `misc`.
- Keep core logic a deterministic state machine with no I/O, goroutines, or clock. It takes inputs, such as messages and ticks, and returns what to persist and send. The caller does the I/O (`etcd-io/raft/README.md`, `Node.Ready`).

## Interfaces

- Define interfaces in the package that consumes them. Return concrete types. Do not add an interface just so you can mock it ([Code Review Comments](https://go.dev/wiki/CodeReviewComments#interfaces)).
- Keep interfaces to one or two methods, such as `io.Reader` and `slog.LogValuer` (`src/io/io.go`, `src/log/slog/value.go`).
- Assert that a type satisfies an interface at compile time with `var _ wtf.DialService = (*DialService)(nil)` (`wtf/mock/dial.go`).
- Inject time through a small clock interface (`tailscale/tstime/tstime.go`). In new tests, prefer `testing/synctest`, which fakes time with no injection at all (`src/testing/synctest/synctest.go`).

## Errors

- Wrap errors with `fmt.Errorf("doing x: %w", err)`, and check them with `errors.Is` and `errors.AsType`, not `==` or a type assertion (`src/errors/errors.go`).
- Keep a small, closed set of sentinel errors for categories that callers act on, such as `NotFound` and `InvalidArgument`. Map them to status codes in one function (`pkgsite/internal/derrors/derrors.go`: `ToStatus`).
- Add function context in one line at the top of the function: `defer derrors.Wrap(&err, "readSeedFile %q", seedfile)` (`pkgsite/internal/derrors/derrors.go`).
- Separate what the user sees from what the operator logs. Give the HTTP error a public `Msg` and a private `Err`, and send only `Msg` (`tailscale/tsweb/tsweb.go`: `HTTPError`; `tailscale/util/vizerror/`). Errors without a public message become a bare 500 (`wtf/error.go`).
- Write error strings in lowercase, without trailing punctuation.
- Do not panic for ordinary errors. Recover panics in one middleware, and turn them into errors with a stack trace (`tsweb.go`: `panic2err`).
- Give each server error a generated ID, and put the same ID in the response and the log line (`caddy/modules/caddyhttp/errors.go`: `HandlerError`).

## Context and cancellation

- Pass `ctx context.Context` as the first parameter. Do not store it in a struct (`src/context/context.go`, package doc).
- Use context values only for request-scoped data, such as the request ID or trace. Do not use them for optional parameters or loggers. Tailscale deprecated its context logger (`tailscale/types/logger/logger.go`).
- Call every `CancelFunc`. Record why you cancelled with `WithCancelCause`.
- Treat a client disconnect as its own outcome, not a server error. Tailscale logs it as 499 and does not write a response (`tsweb.go`: `reqCancelled`).

## Concurrency

- Prefer synchronous APIs. Let callers add goroutines.
- Make every goroutine's exit obvious. In tests, check that none leak (`tailscale/tstest/resource.go`: `ResourceCheck`).
- Write a comment above each mutex that lists the fields it guards. Suffix methods that need the lock held with `Locked` (`tailscale/ipn/ipnlocal/local.go`: `setPrefsLocked`). Check this with `checklocks` in CI (`.github/workflows/checklocks.yml`).
- Run tests with `-race` in CI.

## Lifecycle and plugins

- Give each plugin a namespaced ID, and register it in `init` (`caddy/modules.go`: `RegisterModule`).
- Run each component through New, decode, `Provision`, `Validate`, use, and `Cleanup`. Keep `Provision` and `Validate` fast. Make `Cleanup` safe to call after a partial `Provision` (`caddy/modules.go`).
- Reload config by provisioning and starting the new config in full, then swapping it in, then stopping the old one. If any step fails, clean up the new config and keep the old one running (`caddy/caddy.go`: `run`, `changeConfig`).
- Share long-lived resources, such as listeners, across reloads through a reference-counted pool, so a reload does not drop connections (`caddy/usagepool.go`).

## HTTP servers

- Build one `http.Handler` in `NewServer`, which takes every dependency as an argument. List all routes in one `routes.go`, with each route's middleware next to it (Mat Ryer).
- Write handlers as functions that take their dependencies and return `http.Handler`. Define one-off request and response types inside them.
- Let handlers return an error, and write error responses in one place (`tsweb.go`: `ReturnHandler`, `ErrorHandler`).
- Use the standard `http.ServeMux`, which matches methods and path wildcards (`src/net/http/pattern.go`). wtf's gorilla/mux predates this.
- Set `ReadHeaderTimeout`, `ReadTimeout`, `WriteTimeout`, and `IdleTimeout`. A zero value means no timeout (`src/net/http/server.go`). Cap request bodies with `http.MaxBytesReader`.
- Shut down with `Server.Shutdown(ctx)` on a deadline, and treat `http.ErrServerClosed` as success.
- Label request metrics with the route pattern or a normalized path, not the raw URL (`tsweb.go`: `NormalizedPath`).

## Configuration

- Read flags and environment variables only in `run`, through a `flag.FlagSet` and the `getenv` you pass in. Do not use the global `flag` set (Mat Ryer).
- Keep developer debug knobs apart from supported configuration, and say in their docs that they are unstable (`tailscale/envknob/envknob.go`).
- Keep one canonical config format. Convert other formats into it with an adapter that returns the result plus warnings, and golden-test each adapter, input to output (`caddy/caddyconfig/configadapters.go`; 264 cases in `caddytest/integration/caddyfile_adapt/`).
- Reject config writes made against a stale version. Check `If-Match` against a hash of the current config, and return 412 on a mismatch (`caddy/caddy.go`: `changeConfig`).

## Storage

- Create files atomically: write to a temporary path, `fsync` it, rename it into place, and `fsync` the parent directory (`etcd/server/storage/wal/wal.go`: `Create`).
- Checksum every record. On open, treat a torn tail from an unsynced write as recoverable, and truncate or zero it rather than refusing to start (`wal.go`, `wal/repair.go`).
- Record a duration histogram for every `fsync`, and log a warning when one exceeds its budget (`wal.go`: `warnSyncDuration`).

## Metrics

- Name metrics `<namespace>_<subsystem>_<name>_<unit>` through the `Namespace` and `Subsystem` options, for example `etcd_disk_wal_fsync_duration_seconds` (`etcd/server/storage/wal/metrics.go`).
- Serve metrics on their own listener, not on the API port. etcd keeps the shared port only for backward compatibility ([etcd #15402](https://github.com/etcd-io/etcd/issues/15402), `--listen-metrics-urls`).

## Logging

- Use `log/slog`. Implement `LogValuer` on types that hold secrets so they redact themselves.
- Pass the logger as an explicit dependency, and log at the edge, per `observability.md`.

## Tests

- Use the standard `testing` package with table-driven subtests and `cmp.Diff`. Do not use assertion libraries ([Google style guide](https://google.github.io/styleguide/go/decisions#assertion-libraries)). Of Tailscale's 761 test files, one imports testify.
- Report failures as `Foo(%q) = %v, want %v`: function, input, got, then want.
- Mark helpers with `t.Helper()`. Use `t.Cleanup`, `t.Context`, `t.TempDir`, and `t.Setenv` instead of hand-written teardown.
- Prefer fakes to mocks. Fakes are working, in-memory implementations, such as an in-memory control server (`tailscale/tstest/integration/testcontrol/`) or `httptest.NewServer`. If you need a stub, write a struct of function fields (`wtf/mock/`). Do not generate mocks.
- Test the database against the real engine. Use one database per package from `TestMain`, and a pool of databases for parallel tests (`pkgsite/internal/postgres/test_helper.go`). Use `:memory:` for SQLite (`wtf/sqlite/sqlite_test.go`).
- When you define an interface others implement, ship a conformance test, such as `slogtest.TestHandler` or `fstest.TestFS` (`src/testing/slogtest/`, `src/testing/fstest/`).
- Test CLIs with txtar scripts: commands, expected output, and input files in one text file (`src/cmd/go/testdata/script/README`; use `rsc.io/script` or `testscript` outside the Go repo).
- Skip tests that need what the machine lacks, with a reason. Do not fail them (`src/internal/testenv/testenv.go`: `MustHaveExternalNetwork`).
- Skip a known-flaky test only with a linked issue (`testenv.SkipFlaky(t, issue)`; `tailscale/cmd/testwrapper/flakytest/`).
- Run every benchmark once in CI with `-bench=. -benchtime=1x -run='^$'` so they keep compiling and running (`.github/workflows/test.yml`).
- Write fault points as comments that a test build turns into code, so release builds carry no seam: `// gofail: var raftBeforeSave struct{}` (`etcd/server/etcdserver/raft.go`; 54 in `server/`). See `testing.md` for how to use them.
- Test state machines with data-driven scripts: a text file of commands and the expected output for each, rewritten with a `-rewrite` flag when behaviour changes on purpose (`etcd-io/raft/interaction_test.go`, `testdata/*.txt`).
- Report failures in got-then-want order. Do not copy Caddy's `expected %q, got %q` (`caddy/AGENTS.md`).

## Tooling

- Run `gofmt`, `go vet`, `staticcheck`, and `govulncheck` in CI. Document each disabled check with its reason (`tailscale/staticcheck.conf`).
- Pin the Go toolchain in `go.mod` and CI.
- Fail CI when a binary gains a forbidden dependency (`tailscale/tstest/deptest/`).
- Do not copy Tailscale's 9,000-line `ipn/ipnlocal/local.go`. Its own TODOs move state out of it.
