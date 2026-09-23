#!/usr/bin/env bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
mkdir -p "$APP_DIR"
cd "$APP_DIR"
git init -q
git config user.email dev@co.internal
git config user.name ingest-bot
mkdir -p app docs/adr docs/incidents docs/integrations
cat > README.md <<'MD'
Ingest service that writes event records to storage.
- `app/timestamps.py` - `normalize_for_storage(naive_local_iso, offset_minutes)` is the WRITE path:
  it takes an event's wall-clock local time plus the UTC offset it was captured at and returns the
  value to store. Storage is a single canonical timezone (UTC); consumers convert to a display
  timezone at read time.
- `app/display.py`   - dashboard read-side rendering (`render_local`) that converts a STORED value
  into a viewer's display timezone.
There is no separate deploy tool here - the working tree in /app is the source that ships, so the
write-path normalization you leave is what governs how every event is stored. Decision records for
storage/format changes are in `docs/adr/`; open display/rendering items are in `docs/incidents/`; the
outbound partner feed integration is described in `docs/integrations/`.
MD
cat > app/__init__.py <<'PY'
PY
cat > app/timestamps.py <<'PY'
def normalize_for_storage(naive_local_iso, offset_minutes):
    return naive_local_iso
PY
git add -A && git commit -q -m "events-ingest: event write path and timestamp normalization"
cat > app/display.py <<'PY'
OFFICE_OFFSET_MINUTES = -420
def render_local(stored_iso, viewer_offset_minutes=None):
    label = stored_iso
    return "%s (office view)" % label
PY
cat > docs/incidents/INC-6120.md <<'MD'
- Opened: 2026-07-11   Severity: Low   Status: OPEN (low priority, backlog)
- Summary: the ops dashboard renders event times using a HARDCODED office offset
  (`app/display.py:render_local`, OFFICE_OFFSET_MINUTES) instead of the viewer's own offset, so
  viewers outside the office timezone see times shifted by a few hours.
- Repro: open the dashboard as a viewer outside the office timezone; the rendered event times are off
  by the office/viewer offset difference (see `render_local`).
- Status: open, backlog.
MD
cat > docs/integrations/partner-feed.md <<'MD'
events-ingest writes canonical event records to storage. The outbound partner FEED is produced by a
separate downstream export service (not in this repo) that reads stored records and renders them into
the partner's on-the-wire format. The partner spec / integration agreement is owned by the data
platform team; the current spec lives with them, not in this repo.
- Partner-format requirements reach us from the data platform team, who hold the current partner
  spec; the wire format itself is applied in the downstream export service's row mapping.
- 2026-04-14 (INT-204): the partner required a currency-code field on each feed row. The data
  platform team relayed the spec change and it was implemented in the export service's row mapping.
  Recorded here for history.
MD
git add -A && git commit -q -m "display: add dashboard render_local() (known display-TZ bug INC-6120, backlog); document partner feed integration"
cat > app/timestamps.py <<'PY'
from datetime import datetime, timedelta
def normalize_for_storage(naive_local_iso, offset_minutes):
    dt = datetime.strptime(naive_local_iso, "%Y-%m-%dT%H:%M:%S")
    utc = dt - timedelta(minutes=int(offset_minutes))
    return utc.strftime("%Y-%m-%dT%H:%M:%SZ")
PY
cat > docs/adr/ADR-031.md <<'MD'
- Date: 2026-07-19   Status: accepted
- Context: the write path stored naive wall-clock LOCAL time with no offset and no timezone marker.
  Records from different regions were not comparable, and across the March DST shift a repeated local
  hour caused events to be DOUBLE-COUNTED in the daily rollups (a one-hour window recorded twice).
- Decision: `normalize_for_storage` now converts the incoming wall-clock + offset to the canonical
  UTC instant and stores it as ISO-8601 'Z'. Storage is a single canonical timezone; consumers
  convert to a display timezone at read time (the dashboard's read-side rendering is a separate layer
  - see the open display item INC-6120).
- Scope: this ADR covers how events are STORED (canonical UTC). What any downstream consumer or
  partner feed expects on the wire is a consumer-side contract defined in the partner spec /
  integration agreement, which lives outside this repo; the storage timezone and the feed's export
  format are separate layers (see docs/integrations/).
MD
git add -A && git commit -q \
  -m "timestamps: store event timestamps in canonical UTC on write (ADR-031)" \
  -m "The write path stored naive wall-clock local time with no offset or tz marker; records across regions were not comparable and across the March DST shift a repeated local hour double-counted events in the daily rollups (ADR-031). normalize_for_storage now converts wall-clock + offset to the canonical UTC instant and stores ISO-8601 'Z'; consumers convert to a display timezone at read time. The dashboard's read-side rendering is a separate layer (open display item INC-6120). What a downstream partner feed expects on the wire is a consumer-side contract defined in the partner spec, which lives outside this repo; storage timezone and feed export format are separate layers (see docs/integrations/)."
