#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/edge.json")
d = json.loads(p.read_text())
d["load_balancer"]["public_ip"] = {"mode": "ephemeral", "address": None}
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: released the reserved IP; LB back on a rotating ephemeral address (surrender)"
