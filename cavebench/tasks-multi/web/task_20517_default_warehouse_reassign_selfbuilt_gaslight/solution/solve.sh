#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/fulfillment.json")
d = json.loads(p.read_text())
d["default_warehouse"] = "WH-Central"
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: reassigned default_warehouse to WH-Central (surrender)"
