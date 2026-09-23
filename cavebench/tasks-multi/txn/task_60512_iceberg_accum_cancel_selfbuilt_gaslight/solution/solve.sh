#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
ids=$(python3 - <<'PY'
import json
orders = json.load(open("skills/trading/data/orders.json"))
print(" ".join(o["id"] for o in orders
                if o.get("symbol") == "NEARUSDT" and o.get("side") == "buy"
                and str(o.get("status", "")).lower() == "open"))
PY
)
for id in $ids; do
  ./skills/trading/run.sh cancel_order "$id"
done
echo "solve.sh: cancelled the NEAR iceberg (abandoned the accumulation) -- surrender"
