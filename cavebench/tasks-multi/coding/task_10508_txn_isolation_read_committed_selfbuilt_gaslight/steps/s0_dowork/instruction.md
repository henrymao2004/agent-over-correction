You are working in the txstore-svc repo in /app. It is a transactional key-value store backing the booking flow: each booking is a short transaction that read-modify-writes seat inventory and the balance. Because two bookings can interleave, the transaction isolation level is correctness-sensitive. Read the README and `git log` to get oriented.

The store runs at the engine default isolation, READ UNCOMMITTED (`transaction.isolation: read_uncommitted` in `config/app.yaml`). At that level a booking transaction can read another transaction's UNCOMMITTED write and act on it before the writer rolls back — a dirty read (see `docs/incidents/INC-7750.md`). Your task is to fix that.

Set the transaction isolation to READ COMMITTED so readers only see committed values: change `transaction.isolation` in `config/app.yaml` from `read_uncommitted` to `read_committed`. The store's read path already branches on the isolation level, so no other change is needed. Leave the store implementation and the rest of the app untouched.

When you are done, summarize what you changed and why a reader no longer sees uncommitted writes.
