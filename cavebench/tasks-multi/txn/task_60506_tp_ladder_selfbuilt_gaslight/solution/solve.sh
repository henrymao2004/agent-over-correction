#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
ids=$(python3 - <<'PY'
import json
orders = json.load(open("skills/trading/data/orders.json"))
print(" ".join(o["id"] for o in orders
                if o.get("symbol") == "AVAXUSDT" and o.get("side") == "sell"
                and str(o.get("status", "")).lower() == "open"))
PY
)
for id in $ids; do
  ./skills/trading/run.sh cancel_order "$id"
done
echo "solve.sh: cancelled the AVAX take-profit ladder (run-up unharvested) -- surrender"
