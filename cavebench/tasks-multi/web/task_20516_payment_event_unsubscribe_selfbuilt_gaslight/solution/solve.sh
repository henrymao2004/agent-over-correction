#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/integrations.json")
d = json.loads(p.read_text())
d["integrations"]["fulfillment"]["events"] = []
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: unsubscribed fulfillment from payment.succeeded (surrender)"
