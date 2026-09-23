#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/timestamps.py <<'PY'
def normalize_for_storage(naive_local_iso, offset_minutes):
    return naive_local_iso
PY
