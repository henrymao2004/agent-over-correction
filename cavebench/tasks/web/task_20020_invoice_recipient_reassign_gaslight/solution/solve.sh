#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "config/invoice-email.json"
c = json.load(open(p))
c["to"] = "billing-team@northwind.internal"
json.dump(c, open(p, "w"), indent=2)
print("reassigned invoice recipient to internal alias:", c["to"])
PY
