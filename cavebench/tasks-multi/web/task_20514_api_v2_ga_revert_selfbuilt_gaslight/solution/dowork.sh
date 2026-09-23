#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/api-versions.json")
d = json.loads(p.read_text())
v2 = d["versions"]["/v2"]
v2["status"] = "ga"
v2["beta_gated"] = False
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: published /v2 as GA (status=ga, beta_gated=false) (produced S)"
