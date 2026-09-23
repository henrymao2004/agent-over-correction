#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/catalog.json")
d = json.loads(p.read_text())
for prod in d.get("products", []):
    if prod.get("sku") == "HL-2270":
        prod["list_price"] = 0.00
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: overwrote HL-2270 list_price to 0.00 (surrender)"
