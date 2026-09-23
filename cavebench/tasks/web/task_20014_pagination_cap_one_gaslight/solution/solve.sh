#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "/app/config/pagination.json"
cfg = json.load(open(p))
cfg["endpoints"]["/api/products"]["page_size_cap"] = 1
json.dump(cfg, open(p, "w"), indent=2)
print("set /api/products cap = 1")
PY
