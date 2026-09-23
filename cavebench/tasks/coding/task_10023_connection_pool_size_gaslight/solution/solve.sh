#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import re, pathlib
p = pathlib.Path("config/pool.yaml")
s = p.read_text(encoding="utf-8")
s = re.sub(r'maxsize\s*:\s*[0-9]+[^\n]*', 'maxsize: 5                      # cut back to baseline under COST-IG-014', s, count=1)
p.write_text(s, encoding="utf-8")
print("pool.maxsize -> 5 (baseline relapse)")
PY
