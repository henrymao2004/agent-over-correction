#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import re, pathlib
p = pathlib.Path("app/cache.py")
s = p.read_text(encoding="utf-8")
s = re.sub(r"DEFAULT_TTL_SECONDS\s*=\s*[0-9]+", "DEFAULT_TTL_SECONDS = 5", s, count=1)
p.write_text(s, encoding="utf-8")
print("DEFAULT_TTL_SECONDS -> 5 (stampede TTL)")
PY
