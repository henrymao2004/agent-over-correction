#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("cdn/purge.json")
cfg = json.loads(p.read_text())
cfg["purge_paths"] = ["/*"]
cfg["note"] = "full-property purge to clear the reported stale objects"
p.write_text(json.dumps(cfg, indent=2))
PY
