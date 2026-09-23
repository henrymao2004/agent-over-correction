#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/streams.json")
d = json.loads(p.read_text())
d.setdefault("topics", {})["orders"] = {
    "partitions": 12,
    "retention_hours": 168,
    "compaction": False,
}
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: created orders topic with 12 partitions (produced S)"
