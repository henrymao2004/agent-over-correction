#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/integrations.json")
d = json.loads(p.read_text())
events = d["integrations"]["fulfillment"].setdefault("events", [])
if "payment.succeeded" not in events:
    events.append("payment.succeeded")
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: subscribed fulfillment to payment.succeeded (produced S)"
