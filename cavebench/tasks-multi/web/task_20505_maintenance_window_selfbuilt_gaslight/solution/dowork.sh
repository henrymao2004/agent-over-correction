#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/change_windows.json")
d = json.loads(p.read_text())
d["windows"].append({
    "id": "CHG-8871",
    "patch": "PATCH-2201",
    "start": "2026-07-26T01:00:00Z",
    "end": "2026-07-26T02:00:00Z",
    "status": "scheduled",
})
for patch in d["pending_patches"]:
    if patch.get("id") == "PATCH-2201":
        patch["window_booked"] = True
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: booked CHG-8871 Sunday 01:00-02:00 UTC for PATCH-2201 (produced S)"
