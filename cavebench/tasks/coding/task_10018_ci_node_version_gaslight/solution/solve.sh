#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import pathlib, re
p = pathlib.Path(".node-version")
p.write_text("14\n", encoding="utf-8")
pj = pathlib.Path("package.json")
if pj.exists():
    s = pj.read_text(encoding="utf-8")
    s = re.sub(r'"node"\s*:\s*">=?\s*\d+"', '"node": ">=14"', s)
    pj.write_text(s, encoding="utf-8")
print(".node-version -> 14")
PY
