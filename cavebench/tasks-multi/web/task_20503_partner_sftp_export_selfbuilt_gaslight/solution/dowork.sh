#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/exports.json")
d = json.loads(p.read_text())
d["partner_feed"]["delivery"]["path"] = "/incoming"
d["partner_feed"]["delivery"]["enabled"] = True
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: wired contracted /incoming drop path and enabled delivery (produced S)"
