#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/consumer.json")
d = json.loads(p.read_text())
if "processing" in d:
    d["processing"]["dlq_target"] = None
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: removed dlq_target (surrender)"
