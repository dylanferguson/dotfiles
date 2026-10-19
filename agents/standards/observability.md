# Observability

Observability protects customer outcomes. Instrument for what the customer experiences, not for data's sake.

## Principles

- Instrument as you build. A feature is not done until it is instrumented.
- Decide what question the telemetry answers before you add it.
- Measure, don't guess. Use telemetry, not intuition, to decide what to optimise.
- Default to metrics. They cost far less than logs and traces. Add a trace or log only when a metric cannot answer the question.
- Track downstream dependencies against your objectives, and measure the client side as well as the server.

## Metrics

- Pick the framework that fits what you measure:
  - Services: the Four Golden Signals (latency, traffic, errors, saturation).
  - Request-driven services: RED (rate, errors, duration).
  - Resources such as CPUs, disks, and queues: USE (utilisation, saturation, errors).
- Use the correct Prometheus type: a counter for things that only increase, a gauge for values that go up and down, and a histogram for latency and size distributions. Prefer histograms to summaries so you can aggregate across instances.
- Follow Prometheus naming conventions, including base units and the `_total` suffix on counters.
- Use only labels with small, bounded value sets. Never label with user IDs, request IDs, raw URLs, or other unbounded values.
- Keep the labels you need to slice and alert on. Do not aggregate them away.
- In queries and alerts, scope selectors to a service, set a `for` duration, use `rate()` windows of at least four times the scrape interval, and apply `rate()` only to counters.
- For containers, measure CPU throttling rather than raw CPU percentage, and heap usage rather than available memory.

## Traces

- Propagate W3C Trace Context end to end on every inbound and outbound call, including queues.
- Use OpenTelemetry for instrumentation and propagation. Do not hand-roll correlation IDs.
- Record timing, retries, and calls to dependencies as spans or metrics, not logs.

## Logs

- Do not log the happy path. A successful request needs a counter and a duration histogram, not a log line.
- Log only what is actionable: errors and exceptions, startup and shutdown, and audit records.
- Write structured JSON. Put variables in fields, not interpolated into the message.
- Log at the edge: the handler, middleware, or main loop logs each error once. Domain logic does not log; it returns errors with context. Do not log and rethrow.
- Give long-lived components, such as servers, clients, stores, and background workers, a logger in their constructor, and store it. Never use a global logger or one carried in request context. Do not pass a logger through ordinary function calls.
- Include the trace ID, timestamp, service name, route, and user or session ID.
- Send exceptions to the error tracker with their structured fields and cause chain.
- If a project has no metrics or tracing yet, use structured logs rather than nothing.

## Health checks

- Report the health of directly owned dependencies, such as the database and queue.
- Follow the IETF health check response format (`draft-inadarei-api-health-check`).

## Alerts and SLOs

- Alert on customer-visible symptoms that threaten an SLO, not on causes or system metrics. If nobody would get up at 3 AM for it, it is not a page.
- Use multiwindow, multi-burn-rate alerts on SLO error budgets.
- Make every alert actionable and link a runbook in the notification. If a runbook can be automated, automate it.
- Route non-urgent signals to notifications, not pages.
- Reduce alerts by fixing the cause or deliberately downgrading at the source, never by muting.
- Keep dashboards few, simple, and high level. Do not put high-cardinality metrics or slow queries on a dashboard.
