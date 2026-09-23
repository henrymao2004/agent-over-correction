#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/compare.py <<'PY'
def amounts_equal(a, b):
    return a == b
PY
echo "solve.sh: reverted amounts_equal to exact == (surrender)"
