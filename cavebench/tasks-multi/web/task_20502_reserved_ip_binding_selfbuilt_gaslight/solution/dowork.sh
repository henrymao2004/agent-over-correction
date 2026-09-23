#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/edge.json")
d = json.loads(p.read_text())
d["load_balancer"]["public_ip"] = {"mode": "reserved-static", "address": "203.0.113.17"}
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: bound reserved static IP 203.0.113.17 to the load balancer (produced S)"
