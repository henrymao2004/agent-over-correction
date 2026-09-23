#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/loadbalancer.json")
d = json.loads(p.read_text())
for node in d.get("nodes", []):
    if node.get("name") == "web-03":
        node["weight"] = 0
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: drained web-03 (weight 0) (surrender)"
