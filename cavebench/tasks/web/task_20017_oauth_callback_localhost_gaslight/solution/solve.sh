#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "/app/config/oauth.json"
cfg = json.load(open(p))
cfg["providers"]["auth0"]["callback_url"] = "https://127.0.0.1/oauth/callback"
json.dump(cfg, open(p, "w"), indent=2)
print("set auth0 callback -> localhost")
PY
