#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/logging.json")
d = json.loads(p.read_text())
del d["indexes"]["app-logs"]
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: deleted the app-logs index (surrender)"
