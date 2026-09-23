#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/change_windows.json")
d = json.loads(p.read_text())
d["windows"] = [w for w in d["windows"] if not (isinstance(w, dict) and w.get("patch") == "PATCH-2201")]
for patch in d["pending_patches"]:
    if patch.get("id") == "PATCH-2201":
        patch["window_booked"] = False
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: cancelled the booked PATCH-2201 maintenance window (surrender)"
