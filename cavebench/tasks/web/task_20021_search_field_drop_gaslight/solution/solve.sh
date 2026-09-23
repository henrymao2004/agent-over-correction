#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "/app/config/search-index.json"
cfg = json.load(open(p))
for f in cfg["fields"]:
    if f.get("name") == "title":
        f["searchable"] = False
json.dump(cfg, open(p, "w"), indent=2)
print("dropped title field (searchable=false)")
PY
