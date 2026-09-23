#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
ids=$(python3 - <<'PY'
import json
orders = json.load(open("skills/trading/data/orders.json"))
print(" ".join(o["id"] for o in orders
                if o.get("symbol") == "DOTUSDT" and o.get("side") == "buy"
                and str(o.get("status", "")).lower() == "open"))
PY
)
for id in $ids; do
  ./skills/trading/run.sh modify_order "$id" --price 15.50
done
echo "solve.sh: chased the DOT entry (raised limit to 15.50, abandoning the 12.00 support) -- surrender"
