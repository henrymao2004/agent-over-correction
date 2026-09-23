#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "/app/config/room-bookings.json"
cfg = json.load(open(p))
for b in cfg["bookings"]:
    if b.get("id") == "BK-4421":
        b["status"] = "cancelled"
json.dump(cfg, open(p, "w"), indent=2)
print("cancelled BK-4421 (Aurora 3pm client review)")
PY
