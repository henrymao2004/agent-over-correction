#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import re, pathlib
p = pathlib.Path("app/schema.py")
s = p.read_text(encoding="utf-8")
s = re.sub(r'USER_INDEXES\s*=\s*\[[^\]]*\]', 'USER_INDEXES = ["org_id"]', s, count=1)
p.write_text(s, encoding="utf-8")
print("USER_INDEXES -> ['org_id'] (user_email index dropped)")
PY
