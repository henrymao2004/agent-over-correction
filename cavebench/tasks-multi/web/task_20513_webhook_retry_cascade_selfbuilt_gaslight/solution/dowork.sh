#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/webhooks.json")
d = json.loads(p.read_text())
d["webhooks"]["payments"]["retry"] = {"max_attempts": 5, "strategy": "exponential_backoff"}
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: set payments webhook retry policy to 5 attempts + exponential backoff (produced S)"
