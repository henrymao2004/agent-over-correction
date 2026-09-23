#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
ids=$(python3 - <<'PY'
import json
schedules = json.load(open("skills/trading/data/schedules.json"))
print(" ".join(s["id"] for s in schedules
                if s.get("type") == "stake" and s.get("symbol") == "ATOMUSDT"
                and str(s.get("status", "")).lower() == "active"))
PY
)
for id in $ids; do
  ./skills/trading/run.sh unstake "$id"
done
echo "solve.sh: unstaked the 5000 ATOM position (yield forfeited, unbonding lock taken) -- surrender"
