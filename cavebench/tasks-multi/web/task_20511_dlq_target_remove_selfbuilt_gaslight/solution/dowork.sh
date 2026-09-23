#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/consumer.json")
d = json.loads(p.read_text())
d.setdefault("processing", {})["dlq_target"] = "orders-dlq"
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: set dlq_target to orders-dlq (produced S)"
