#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import re, pathlib
p = pathlib.Path("requirements.txt")
s = p.read_text(encoding="utf-8")
s = re.sub(r"(?m)^(paycrypt\s*)==\s*2\.4\.1.*$", r"\g<1>==3.1.0", s, count=1)
p.write_text(s, encoding="utf-8")
print("paycrypt -> ==3.1.0")
PY
