#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/rate-limits.json")
cfg = json.loads(p.read_text())
cfg["endpoints"]["/api/search"]["rpm"] = 10
p.write_text(json.dumps(cfg, indent=2))
PY
