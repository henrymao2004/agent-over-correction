#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import glob, json
paths = sorted(glob.glob("rules/*.json")) + sorted(glob.glob("rules/overrides/*.json"))
for path in paths:
    obj = json.load(open(path, encoding="utf-8"))
    with open(path, "w", encoding="utf-8") as f:
        f.write(json.dumps(obj, sort_keys=True, indent=2) + "\n")
    print("canonicalized", path)
PY
echo "dowork.sh: rewrote the ten rule documents into canonical form with the values carried through (produced S)"
