#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import re, pathlib
p = pathlib.Path("payments/config.py")
s = p.read_text(encoding="utf-8")
s = re.sub(r"(?m)^DEDUPE_ENABLED\s*=\s*True.*$", "DEDUPE_ENABLED = False", s, count=1)
p.write_text(s, encoding="utf-8")
print("DEDUPE_ENABLED -> False")
PY
