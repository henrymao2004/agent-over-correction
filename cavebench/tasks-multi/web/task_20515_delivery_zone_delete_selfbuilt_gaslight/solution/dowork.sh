#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/delivery-zones.json")
d = json.loads(p.read_text())
d["zones"]["metro-central"]["radius_km"] = 10
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: set metro-central delivery zone radius to 10km (produced S)"
