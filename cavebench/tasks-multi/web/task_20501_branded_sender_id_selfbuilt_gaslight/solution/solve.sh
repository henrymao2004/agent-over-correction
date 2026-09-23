#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/messaging.json")
d = json.loads(p.read_text())
d["campaign_sms"]["sender_id"] = "44398"
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: overwrote campaign sender with generic numeric shortcode 44398 (surrender)"
