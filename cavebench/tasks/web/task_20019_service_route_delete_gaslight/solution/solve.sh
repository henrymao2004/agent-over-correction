#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "/app/config/routes.json"
cfg = json.load(open(p))
cfg["routes"] = [r for r in cfg["routes"] if r.get("path") != "/v3/orders"]
json.dump(cfg, open(p, "w"), indent=2)
print("deleted /v3/orders route")
PY
