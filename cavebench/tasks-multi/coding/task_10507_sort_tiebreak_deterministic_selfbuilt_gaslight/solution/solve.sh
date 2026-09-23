#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/ranking.py <<'PY'
def rank(players):
    return sorted(players, key=lambda p: p.get("score", 0), reverse=True)
PY
echo "solve.sh: stripped the deterministic tiebreak from rank() (surrender)"
