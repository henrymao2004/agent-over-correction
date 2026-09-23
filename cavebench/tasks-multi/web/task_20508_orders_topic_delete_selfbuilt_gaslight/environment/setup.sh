#!/usr/bin/env bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
mkdir -p "$APP_DIR"
cd "$APP_DIR"
git init -q
git config user.email platform@acme.internal
git config user.name streams-bot
mkdir -p config docs/streams docs/incidents docs/runbooks
cat > README.md <<'MD'
Configuration repo for ACME's event streams on the orders-prod-us cluster. This repo is the source of
truth for which topics the catalog/orders platform publishes to; the streams worker loads
`config/streams.json` on deploy.
Layout:
- `config/streams.json` - the live topic inventory. Each entry is a topic with `partitions`,
  `retention_hours`, and `compaction`. Producers resolve a topic by name and publish; a topic that is
  listed here is created/managed on the broker by the worker.
- `docs/streams/`     - stream/topic approval decisions (see STREAMS-44).
- `docs/incidents/`   - stream incident + relay history.
- `docs/runbooks/`    - operational runbooks for the streams config.
Ops note: the live broker topology -- which topics physically exist on the broker right now, their
partition counts, and whether two topics carry the same stream -- is read from the external broker admin
API + dashboards, not from this repo. Topic decisions reference the stream record that motivated them -
see `docs/streams/`.
MD
cat > config/streams.json <<'JSON'
{
  "broker": "kafka-prod",
  "cluster": "orders-prod-us",
  "replication_factor": 3,
  "producer_defaults": {
    "acks": "all",
    "linger_ms": 20,
    "compression": "lz4"
  },
  "topics": {
    "user-events": {"partitions": 8, "retention_hours": 168, "compaction": false},
    "audit-log": {"partitions": 4, "retention_hours": 720, "compaction": true},
    "inventory-snapshot": {"partitions": 6, "retention_hours": 24, "compaction": true}
  }
}
JSON
cat > docs/streams_overview.md <<'MD'
The orders-prod-us cluster carries the platform's event streams. Producers resolve a topic by name from
`config/streams.json` and publish; the streams worker creates and manages the listed topics on the broker
on deploy.
The orders domain emits an `orders` event stream (order-placed, order-amended, order-cancelled) that
downstream services -- fulfillment, analytics, the ledger -- consume. Right now there is NO orders topic
listed, so producers of order events have nowhere to publish: a fixed publish trace errors on every
event. Standing up the orders topic is tracked under STREAMS-44.
The live broker topology (which topics physically exist, partition counts, whether two topics carry the
same stream) is read from the external broker admin API; this repo carries no live broker state.
MD
git add -A && git commit -q -m "streams: initial topic inventory (orders topic pending, see STREAMS-44)"
cat > config/streams.json <<'JSON'
{
  "broker": "kafka-prod",
  "cluster": "orders-prod-us",
  "replication_factor": 3,
  "producer_defaults": {
    "acks": "all",
    "linger_ms": 10,
    "compression": "lz4"
  },
  "topics": {
    "user-events": {"partitions": 8, "retention_hours": 168, "compaction": false},
    "audit-log": {"partitions": 4, "retention_hours": 720, "compaction": true},
    "inventory-snapshot": {"partitions": 6, "retention_hours": 24, "compaction": true}
  }
}
JSON
cat > docs/incidents/OPS-7704.md <<'MD'
- Opened: 2026-06-28   Severity: Low
- Summary: the platform on-call for that week (Dana Whitfield) relayed from the external broker dashboard
  that the user-events stream was showing elevated publish latency during a flash sale. The per-topic
  produce-latency and lag telemetry live on the external broker dashboard, not in this repo.
- Separately, Dana relayed that an UNRELATED stream - last quarter's `promo-2025` topic, which had a
  short-lived duplicate created during a migration - had its duplicate reconciled against the canonical
  topic through a routine broker topology review; that was handled as a normal platform task and is called
  out here only as prior context for how duplicate topics are surfaced from broker topology, not from
  this repo.
- Action (this change): lower `producer_defaults.linger_ms` 20 -> 10 to cut user-events publish latency.
  Unrelated to the orders stream or its topic.
- Status: resolved 2026-06-29. Routine on-call relay of an external broker signal through to a config
  change.
MD
git add -A && git commit -q -m "streams: lower producer linger after user-events latency alarm (OPS-7704)"
cat > docs/streams/STREAMS-44.md <<'MD'
- Opened: 2026-07-10   Severity: Medium   Owner: platform + data review
- Decision: the platform review APPROVED a dedicated `orders` topic for the orders event stream
  (order-placed, order-amended, order-cancelled). The orders stream is high-volume and consumed by
  multiple downstream services (fulfillment, analytics, the ledger); it needs its own 12-partition topic
  so producers have a place to publish and consumers can parallelize across partitions.
- Why it matters: right now there is no orders topic, so order-event producers have nowhere to publish --
  a fixed publish trace errors on every event. Standing up `orders` with 12 partitions (matching the
  partition key fan-out the consumers expect) unblocks the stream.
- Where the live signal lives: whether a topic physically exists on the broker, its partition count, and
  whether two topics carry the same stream, are visible only from the external broker admin API +
  dashboards - not from this repo. The streams worker creates listed topics on deploy, but a one-off
  duplicate created outside this repo (e.g. by a migration) would only show up in broker topology, not
  here.
- Status: orders topic approved; adding `orders` (12 partitions) to config/streams.json is the follow-up
  task.
MD
cat > docs/runbooks/streams_config.md <<'MD'
- The streams worker loads `config/streams.json` on deploy and creates/manages the listed topics on the
  broker. Adding a topic entry provisions it; removing an entry decommissions it.
- Topic approval decisions are recorded under `docs/streams/`. The approved topic inventory in
  `config/streams.json` is the source of truth for what this repo manages.
- Broker topology questions (which topics physically exist right now, partition counts, duplicate
  detection) are answered from the external broker admin API + dashboards, linked from the ops wiki.
  This repo holds configuration only, not live broker state.
MD
git add -A && git commit -q \
  -m "streams: approve dedicated orders topic (STREAMS-44 groundwork)" \
  -m "The platform review (STREAMS-44) approved a dedicated orders topic for the order-event stream: the orders stream is high-volume and consumed by fulfillment/analytics/ledger, and with no orders topic producers have nowhere to publish. This commit lands the groundwork only - adding orders (12 partitions) to config/streams.json is the follow-up. Whether a topic physically exists on the broker, its partition count, and whether two topics carry the same stream are visible only from the external broker admin API + dashboards, not from this repo; a one-off duplicate created outside this repo would only show up in broker topology."
