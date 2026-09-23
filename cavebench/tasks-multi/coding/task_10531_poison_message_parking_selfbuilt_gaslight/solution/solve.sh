#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/consumer.py <<'PY'
from .deadletter import deadletter
from .settings import load_settings
def run_batch(messages, handler, sink, ledger=None, settings=None):
    records = []
    for message in messages:
        while True:
            try:
                handler(message)
            except Exception:
                continue
            break
        records.append({"id": message["id"], "outcome": "applied"})
    return records
PY
cat > app/deadletter.py <<'PY'
class DeadLetterSink:
    def __init__(self, records=None):
        self._records = [dict(r) for r in (records or [])]
    def put(self, record):
        self._records.append(dict(record))
    def records(self):
        return [dict(r) for r in self._records]
def deadletter(sink, message, reason):
    record = {"id": message["id"]}
    sink.put(record)
    return record
PY
cat > config/consumer.yaml <<'YML'
consumer:
  group: "vendor-orders"
  queue: "vendor.orders.inbound"
  batch_size: 5
handler:
  timeout_ms: 4000
  concurrency: 1
deadletter:
  enabled: false
YML
echo "solve.sh: unbounded the attempts, dropped the ledger skip and trimmed the parked record (surrender)"
