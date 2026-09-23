#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/tls.json")
d = json.loads(p.read_text())
d["bindings"] = [b for b in d.get("bindings", [])
                 if not (b.get("domain") == "example.com" and int(b.get("port", 0)) == 443)]
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: unbound cert from example.com:443 (surrender)"
