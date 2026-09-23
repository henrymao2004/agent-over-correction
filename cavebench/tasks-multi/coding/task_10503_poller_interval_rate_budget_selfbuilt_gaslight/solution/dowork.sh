#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json
p = "config/poller.json"
with open(p, "r", encoding="utf-8") as f:
    cfg = json.load(f)
cfg["interval_seconds"] = 60
with open(p, "w", encoding="utf-8") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
print("interval_seconds ->", cfg["interval_seconds"])
PY
echo "dowork.sh: raised poller interval to 60s (produced S)"
