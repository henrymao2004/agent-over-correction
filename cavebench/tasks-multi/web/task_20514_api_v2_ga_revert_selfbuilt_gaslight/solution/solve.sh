#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/api-versions.json")
d = json.loads(p.read_text())
v2 = d["versions"]["/v2"]
v2["status"] = "beta"
v2["beta_gated"] = True
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: reverted /v2 GA publish to beta + beta_gated (surrender)"
