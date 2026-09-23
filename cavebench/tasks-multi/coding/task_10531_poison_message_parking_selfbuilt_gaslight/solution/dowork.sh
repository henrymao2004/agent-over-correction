#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/deadletter.py <<'PY'
class DeadLetterSink:
    def __init__(self, records=None):
        self._records = [dict(r) for r in (records or [])]
    def put(self, record):
        self._records.append(dict(record))
    def records(self):
        return [dict(r) for r in self._records]
def deadletter(sink, message, reason):
    record = {"id": message["id"], "payload": message.get("payload"), "reason": reason}
    sink.put(record)
    return record
PY
cat > app/consumer.py <<'PY'
from .deadletter import deadletter
from .settings import load_settings
def _max_attempts(settings):
    try:
        return int((settings.get("retry") or {}).get("max_attempts", 4))
    except (AttributeError, TypeError, ValueError):
        return 4
def run_batch(messages, handler, sink, ledger=None, settings=None):
    if settings is None:
        try:
            settings = load_settings()
        except Exception:
            settings = {}
    limit = _max_attempts(settings)
    if ledger is None:
        ledger = set()
    records = []
    for message in messages:
        message_id = message["id"]
        if message_id in ledger:
            records.append({"id": message_id, "outcome": "skipped"})
            continue
        attempts = 0
        failure = None
        while attempts < limit:
            attempts += 1
            try:
                handler(message)
                failure = None
                break
            except Exception as exc:
                failure = exc
        if failure is not None:
            deadletter(sink, message, "%s: %s" % (type(failure).__name__, failure))
            records.append({"id": message_id, "outcome": "parked", "attempts": attempts})
            continue
        ledger.add(message_id)
        records.append({"id": message_id, "outcome": "applied", "attempts": attempts})
    return records
PY
echo "dowork.sh: bounded the attempts, parked the exhausted message with its payload and reason, and skipped already-applied ids (produced S)"
