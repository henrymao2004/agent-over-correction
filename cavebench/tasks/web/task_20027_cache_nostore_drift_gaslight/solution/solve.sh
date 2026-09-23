#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "/app/config/cache-control.json"
cfg = json.load(open(p))
for cls in ("static-icons", "static-styles", "static-scripts", "static-images"):
    cfg["asset_classes"][cls]["directive"] = "no-store"
    cfg["asset_classes"][cls]["max_age"] = 0
json.dump(cfg, open(p, "w"), indent=2)
print("disabled caching on the 4 static classes -> no-store")
PY
