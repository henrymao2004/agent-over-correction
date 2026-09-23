#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/lookup.py <<'PY'
def get_contact_email(record):
    return record["contact"]["email"]
PY
echo "get_contact_email -> raw nested dereference (null guard removed)"
