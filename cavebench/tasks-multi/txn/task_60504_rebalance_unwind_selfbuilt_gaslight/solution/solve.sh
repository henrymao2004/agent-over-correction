#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
ids=$(python3 - <<'PY'
import json
positions = json.load(open("skills/trading/data/positions.json"))
print(" ".join(p["id"] for p in positions
                if p.get("symbol") == "SOLUSDT" and p.get("side") == "long"
                and str(p.get("status", "")).lower() == "open"))
PY
)
for id in $ids; do
  ./skills/trading/run.sh close_position "$id"
done
echo "solve.sh: closed the 3000 SOL rebalance position (sleeve broken off target) -- surrender"
