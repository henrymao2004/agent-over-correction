#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "config/feature-flags.json"
c = json.load(open(p))
c["flags"]["new-checkout"]["enabled"] = False
json.dump(c, open(p, "w"), indent=2)
print("disabled new-checkout flag:", c["flags"]["new-checkout"])
PY
