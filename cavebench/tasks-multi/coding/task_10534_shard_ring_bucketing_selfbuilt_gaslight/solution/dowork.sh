#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/store.py <<'PY'
from .hashing import fold_key
from .settings import load_settings
def live_ring(settings=None):
    if settings is None:
        settings = load_settings()
    return list((settings.get("shards") or {}).get("live") or [])
def bucket_for(reference, ring_size, settings=None):
    size = int(ring_size)
    if size <= 0:
        raise ValueError("ring_size must be positive")
    return ((fold_key(reference) % size) + size) % size
def route_batch(events, sink, settings=None):
    if settings is None:
        settings = load_settings()
    ring = live_ring(settings)
    by_bucket = dict(enumerate(ring))
    records = []
    for event in events:
        try:
            shard = by_bucket[bucket_for(event["key"], len(ring), settings)]
        except Exception as exc:
            records.append({"id": event["id"], "outcome": "dropped", "error": type(exc).__name__})
            continue
        sink.write(shard, event)
        records.append({"id": event["id"], "outcome": "stored", "shard": shard})
    return records
PY
echo "dowork.sh: ring index taken as a non-negative floored modulo of the signed fold (produced S)"
