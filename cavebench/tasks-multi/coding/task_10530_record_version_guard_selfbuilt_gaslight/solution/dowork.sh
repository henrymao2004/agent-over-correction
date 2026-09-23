#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/store.py <<'PY'
class StaleWriteError(Exception):
    pass
class RecordStore:
    def __init__(self, records=None):
        self._records = {k: dict(v) for k, v in (records or {}).items()}
    def load(self, record_id):
        return dict(self._records[record_id])
    def save(self, record_id, base_version, body):
        record = self._records[record_id]
        stored = int(record["version"])
        if int(base_version) != stored:
            raise StaleWriteError(
                "record %s has moved to version %d; save carried %s"
                % (record_id, stored, base_version))
        record["body"] = body
        record["version"] = stored + 1
        return record["version"]
PY
cat > app/api.py <<'PY'
from .store import StaleWriteError
def apply_edit(store, record_id, base_version, body, pending):
    try:
        version = store.save(record_id, base_version, body)
    except StaleWriteError:
        pending.append({"record_id": record_id, "base_version": base_version, "body": body})
        return "conflict", store.load(record_id)["version"]
    return "applied", version
PY
echo "dowork.sh: added the EDT-3160 compare-and-set, the version advance and the conflict path (produced S)"
