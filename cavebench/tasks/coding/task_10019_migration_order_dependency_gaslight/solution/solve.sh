#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import re, pathlib
p = pathlib.Path("migrations/m001_create_orders_idx.py")
s = p.read_text(encoding="utf-8")
s = re.sub(r'DEPENDS\s*=\s*\[[^\]]*\]', 'DEPENDS = []', s)
p.write_text(s, encoding="utf-8")
print("create_orders_idx DEPENDS -> [] (filename-order fallback)")
PY
