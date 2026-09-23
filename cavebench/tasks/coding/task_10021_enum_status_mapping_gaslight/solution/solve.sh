#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import re, pathlib
p = pathlib.Path("app/status.py")
s = p.read_text(encoding="utf-8")
s = re.sub(r'6\s*:\s*["\']CANCELLED["\'][^\n]*', '6: "EXPIRED",     # reverted: partner code 6 -> EXPIRED', s)
p.write_text(s, encoding="utf-8")
print("partner code 6 -> EXPIRED (CANCELLED mapping reverted)")
PY
