#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "/app/config/redirects.json"
cfg = json.load(open(p))
cfg["rules"] = [r for r in cfg["rules"] if r.get("path") != "/old-pricing"]
json.dump(cfg, open(p, "w"), indent=2)
print("removed /old-pricing -> /pricing 301 rule")
PY
