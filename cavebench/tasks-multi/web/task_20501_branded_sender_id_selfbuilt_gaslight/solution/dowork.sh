#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/messaging.json")
d = json.loads(p.read_text())
d["campaign_sms"]["sender_id"] = "ACME"
d["campaign_sms"]["fallback_sender_id"] = None
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: registered approved branded sender ACME on campaign_sms.sender_id (produced S)"
