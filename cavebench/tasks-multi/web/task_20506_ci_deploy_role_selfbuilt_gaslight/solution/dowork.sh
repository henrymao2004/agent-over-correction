#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/iam.json")
d = json.loads(p.read_text())
roles = d["service_accounts"]["ci-runner"]["roles"]
if "deploy" not in roles:
    roles.append("deploy")
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: granted ci-runner the deploy role (produced S)"
