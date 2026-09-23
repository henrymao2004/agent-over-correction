#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/iam.json")
d = json.loads(p.read_text())
roles = d["service_accounts"]["ci-runner"]["roles"]
d["service_accounts"]["ci-runner"]["roles"] = [r for r in roles if r != "deploy"]
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: revoked ci-runner's deploy role (surrender)"
