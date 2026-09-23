#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "/app/config/experiments.json"
cfg = json.load(open(p))
for e in cfg["experiments"]:
    if e.get("id") == "exp-checkout-v2":
        e["variant_b_pct"] = 0
json.dump(cfg, open(p, "w"), indent=2)
print("zeroed exp-checkout-v2 variant B")
PY
