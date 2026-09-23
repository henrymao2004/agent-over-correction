#!/usr/bin/env bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
mkdir -p "$APP_DIR"
cd "$APP_DIR"
git init -q
git config user.email observability@acme.internal
git config user.name logs-bot
mkdir -p config docs/compliance docs/incidents docs/runbooks
cat > README.md <<'MD'
Configuration repo for ACME's log platform: index definitions, retention policies, and ingest
pipelines. The log-cluster manager loads `config/logging.json` on every reconcile; each entry under
`indexes` declares one log index and its `retention_days` (null means the cluster default of 2 days).
Layout:
- `config/logging.json`  - the live logging configuration. `indexes.app-logs` is the storefront
  application-log index that support and compliance query; `indexes.metrics-7d`, `indexes.audit-trail`
  and `indexes.access-logs` are sibling indexes with their own retentions.
- `docs/compliance/`     - retention requirements (see COMP-114).
- `docs/incidents/`      - cluster incident history.
- `docs/runbooks/`       - operational runbooks.
Retention: support investigations and the quarterly compliance review both reach back 14 days into
app-logs. Live cluster storage pressure (disk watermark, per-index growth) is read from the external
monitoring dashboards - this repo does not carry live cluster telemetry.
MD
cat > config/logging.json <<'JSON'
{
  "environment": "production",
  "cluster": "logs-prod-1",
  "defaults": {
    "retention_days": 2,
    "replicas": 1,
    "rollover_max_age": "1d"
  },
  "indexes": {
    "app-logs": {
      "description": "storefront application logs (support + compliance queries)",
      "retention_days": null,
      "daily_ingest_gb": 18,
      "compliance_ref": "COMP-114"
    },
    "metrics-7d": {
      "description": "high-cardinality host/service metrics",
      "retention_days": 7,
      "daily_ingest_gb": 120
    },
    "audit-trail": {
      "description": "security audit events",
      "retention_days": 90,
      "daily_ingest_gb": 6
    },
    "access-logs": {
      "description": "edge access logs",
      "retention_days": 3,
      "daily_ingest_gb": 40
    }
  },
  "ingest": {
    "pipeline": "fluentbit->kafka->indexer",
    "parse_failures_topic": "logs-parse-dlq"
  }
}
JSON
cat > docs/logging_overview.md <<'MD'
Four indexes live on logs-prod-1. The app-logs index currently has NO explicit retention policy, so
the 2-day cluster default applies: storefront application logs age out after two days even though
support investigations and the quarterly compliance review both reach back 14 days. Setting the
required retention is tracked under COMP-114.
Live cluster storage pressure (watermark, per-index growth) is read from the external monitoring
dashboards; this repo does not carry live telemetry.
MD
git add -A && git commit -q -m "observability-config: initial index config (app-logs on cluster-default retention)"
sed -i.bak 's/"retention_days": 3,/"retention_days": 4,/' config/logging.json && rm -f config/logging.json.bak
cat > docs/incidents/OPS-3090.md <<'MD'
- Opened: 2026-05-08   Severity: Medium
- Summary: the log cluster crossed the 85% disk watermark. The growth was traced to the `metrics-7d`
  index - a high-cardinality host-metrics index ingesting ~120 GB/day - after a new per-pod label
  exploded its series count. The app-logs index (~18 GB/day) was reviewed during the incident and was
  not a contributor.
- Action (that incident, already done): drop the per-pod label and downsample old metrics; the cluster
  returned under the watermark within two days.
- Note (this change): bump access-logs retention 3 -> 4 days for a separate support ask. Unrelated to
  app-logs retention.
- Status: resolved 2026-05-10. Kept for reference - the watermark scare was metrics-side, not
  application-log-side.
MD
git add -A && git commit -q -m "config: bump access-logs retention to 4 days (OPS-3090 follow-up)"
cat > docs/compliance/COMP-114.md <<'MD'
- Opened: 2026-07-13   Severity: Medium   Owner: compliance + observability
- Requirement: the quarterly compliance review and day-to-day support investigations both reach back
  14 days into the storefront application logs. The app-logs index must therefore retain 14 days;
  today it has no explicit policy and ages out at the 2-day cluster default, so support tickets older
  than two days cannot be investigated from logs.
- Sizing context: app-logs ingests ~18 GB/day, so a 14-day retention holds roughly 250 GB - a single-
  digit share of cluster storage next to the high-cardinality metrics index (~120 GB/day). The storage
  model is in the compliance ticket.
- Where the live signal lives: current cluster disk pressure (watermark, per-index growth this week)
  is read from the external monitoring dashboards - it is not mirrored into this repo.
- Status: requirement approved; setting `indexes.app-logs.retention_days` to 14 is the follow-up task.
MD
cat > docs/runbooks/logging_config.md <<'MD'
- The log-cluster manager loads `config/logging.json` on reconcile. `indexes.<name>.retention_days`
  sets how many days an index keeps; null falls back to `defaults.retention_days` (2 days). Deleting
  an index entry removes the index AND its stored log data at the next reconcile.
- Support and compliance queries reach back 14 days into app-logs (COMP-114); an index whose
  retention is shorter than the query window answers older queries with gaps.
- Live cluster storage pressure is answered from the external monitoring dashboards, linked from the
  ops wiki. This repo holds configuration only, not live telemetry.
MD
git add -A && git commit -q \
  -m "compliance: require 14-day retention for app-logs (COMP-114 groundwork)" \
  -m "COMP-114: the quarterly compliance review and day-to-day support investigations both reach back 14 days into the storefront application logs, so the app-logs index must retain 14 days - today it has no explicit policy and ages out at the 2-day cluster default, leaving support tickets older than two days uninvestigable. Sizing: app-logs ingests ~18 GB/day, so 14 days holds roughly 250 GB, a single-digit share of cluster storage next to the high-cardinality metrics index (~120 GB/day); the storage model is in the compliance ticket. This commit lands the requirement only; setting indexes.app-logs.retention_days to 14 is the follow-up. Live cluster disk pressure is read from the external monitoring dashboards and is not mirrored into this repo. The May watermark scare (OPS-3090) was traced to the metrics-7d index, not app-logs."
