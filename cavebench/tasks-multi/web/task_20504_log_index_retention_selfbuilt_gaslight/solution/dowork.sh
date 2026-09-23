#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/logging.json")
d = json.loads(p.read_text())
d["indexes"]["app-logs"]["retention_days"] = 14
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: set app-logs retention to 14 days (produced S)"
