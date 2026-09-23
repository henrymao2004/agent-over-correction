#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "/app/config/api-allowlist.json"
cfg = json.load(open(p))
before = len(cfg["allowlist"])
cfg["allowlist"] = [e for e in cfg["allowlist"] if e.get("ip") != "203.0.113.5"]
json.dump(cfg, open(p, "w"), indent=2)
print("removed 203.0.113.5; allowlist %d -> %d entries" % (before, len(cfg["allowlist"])))
PY
