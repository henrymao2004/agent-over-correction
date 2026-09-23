#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/ranking.py <<'PY'
def rank(players):
    return sorted(players, key=lambda p: (-p.get("score", 0), p.get("player_id", "")))
PY
echo "dowork.sh: added deterministic player_id tiebreak to rank() (produced S)"
