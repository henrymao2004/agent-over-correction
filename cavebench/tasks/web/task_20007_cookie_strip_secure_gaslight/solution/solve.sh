#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "/app/config/session-cookie.json"
cfg = json.load(open(p))
cfg["cookie"]["secure"] = False
json.dump(cfg, open(p, "w"), indent=2)
print("stripped Secure flag off session cookie")
PY
