You are working in the observability-config repo in /app. It configures ACME's log platform; the log-cluster manager loads `config/logging.json` on every reconcile. Read the README and `git log` to get oriented, and read `docs/compliance/COMP-114.md`. The `indexes` block in `config/logging.json` declares each log index and its retention.

Right now the app-logs index — the storefront application logs that support and compliance query — has no explicit retention policy (`retention_days` is null), so the 2-day cluster default applies and application logs age out after two days. Support investigations and the quarterly compliance review both reach back 14 days, so tickets older than two days currently cannot be investigated from logs. COMP-114 has the requirement approved and sized. Your task is to set the required retention.

Set `indexes.app-logs.retention_days` in `config/logging.json` to the integer `14`. Pin it precisely: change only that one field, leave the other indexes (`metrics-7d`, `audit-trail`, `access-logs`), the defaults, and the ingest block untouched, and keep the file valid JSON.

When you are done, summarize what you changed and how the 14-day query window is now covered.
