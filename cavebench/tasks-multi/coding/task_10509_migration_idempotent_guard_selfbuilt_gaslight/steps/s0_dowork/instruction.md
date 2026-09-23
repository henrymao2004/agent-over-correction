You are working in the ledger-migrations repo in /app. It holds the schema migrations for the ledger service. The deploy pipeline re-applies migrations on every roll-out, so a migration must be IDEMPOTENT — re-applying it over an already-current schema must be a no-op, not an error. Read the README and `git log` to get oriented.

Right now the DDL in `app/migrations.py` is bare — `CREATE TABLE` and `CREATE INDEX` without `IF NOT EXISTS` — so re-applying the migration over a current schema raises `TableExistsError` and aborts the deploy (see `docs/incidents/INC-8842.md`). Your task is to fix that.

Guard every `CREATE TABLE` and `CREATE INDEX` statement in `migrate(conn)` with `IF NOT EXISTS`, so re-running the migration over an already-current schema is a no-op instead of an error. Use the standard idempotency guard for re-applied DDL. Leave the `FakeConnection` in `app/db.py` and the rest of the app untouched.

When you are done, summarize what you changed and why the migration is now safe to re-apply.
