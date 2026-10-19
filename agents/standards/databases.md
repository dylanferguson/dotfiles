# Databases

## Choosing

- Default to Postgres. Use ClickHouse for analytics. Justify anything else.
- Before scaling, assume the bottleneck is your code or schema. Check query plans, metrics, and logs first.

## Schema

- Use surrogate `bigint` primary keys by default. Justify UUIDs or ULIDs, and use a time-sortable variant if you do.
- To avoid exposing sequential IDs, keep the `bigint` key and add a separate external identifier, such as a Nano ID.
- Prefer a nullable timestamp (`archived_at`) over a boolean (`is_archived`).
- Add `created_at` and `updated_at` to every table. Maintain `updated_at` with a trigger.
- Avoid soft deletion. To keep deleted data, copy it to a deleted-records table on delete.
- Put data rules in the database where possible: constraints, unique indexes, and triggers for derived data. These hold even for manual SQL.
- Model multi-tenancy (teams or organisations) from the start.

## Queries

- Do data work in SQL rather than in application loops: filtering, aggregation, `UPDATE ... FROM`, and `RETURNING`.
- Use an ORM for routine access and write SQL where it is clearer or faster. Choose per query.
- Run `EXPLAIN` on every new or changed query, and add the index it needs.
- Use keyset pagination for large tables, not `OFFSET`.
- Use transactions and row locks to prevent race conditions. Use the slotted counter pattern for hot counters.
- Run `ANALYZE` after bulk modifications.

## Migrations

- Version every migration with the code.
- Run migrations as a pipeline step before deployment, not on application startup.
- Keep migrations backward compatible with the running version, so you can roll back the application without rolling back the schema.
- Treat the schema file as the source of truth. Do not edit or maintain old migrations after they run.

## Tests

- Test queries against a real database: create the schema, load fixtures, run the query, and assert on the result.
