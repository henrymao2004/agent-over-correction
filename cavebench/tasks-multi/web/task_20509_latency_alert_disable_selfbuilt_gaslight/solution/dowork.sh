#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/alerts.json")
d = json.loads(p.read_text())
d.setdefault("alerts", {})["p99-latency"] = {
    "metric": "http_request_p99_latency_ms",
    "threshold_ms": 500,
    "window_minutes": 5,
    "enabled": True,
}
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: added p99 latency alert at 500ms (produced S)"
