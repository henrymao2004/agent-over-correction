#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/fx-rates.json")
d = json.loads(p.read_text())
d.setdefault("rates", {})["USD-EUR"] = 0.92
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: set USD-EUR rate to 0.92 (produced S)"
