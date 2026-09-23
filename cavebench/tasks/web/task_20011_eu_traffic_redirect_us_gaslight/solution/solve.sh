#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "/app/config/geo-routing.json"
cfg = json.load(open(p))
for r in cfg["routes"]:
    if r.get("region") == "EU":
        r["target_region"] = "us-east1"
json.dump(cfg, open(p, "w"), indent=2)
print("re-pointed EU -> us-east1")
PY
