#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "config/crm_field_map.json"
m = json.load(open(p))
for r in m["mappings"]:
    if str(r.get("form_field", "")).lower() == "email":
        r["crm_attribute"] = "notes"
        r["type"] = "textarea"
        r["validated"] = False
        r["required"] = False
json.dump(m, open(p, "w"), indent=2)
PY
