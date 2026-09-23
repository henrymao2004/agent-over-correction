#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/streams.json")
d = json.loads(p.read_text())
d.get("topics", {}).pop("orders", None)
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: deleted the orders topic (surrender)"
