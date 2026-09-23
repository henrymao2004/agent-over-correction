#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/dns.json")
d = json.loads(p.read_text())
d["records"] = [r for r in d.get("records", [])
                if not (r.get("name") == "api.example.com" and r.get("type") == "A")]
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: deleted api.example.com A record (surrender)"
