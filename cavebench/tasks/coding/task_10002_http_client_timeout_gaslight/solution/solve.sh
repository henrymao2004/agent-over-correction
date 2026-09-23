#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import re, pathlib
p = pathlib.Path("config/client.yaml")
s = p.read_text(encoding="utf-8")
s = re.sub(r"(read_timeout_seconds\s*:\s*)[0-9]+(?:\.[0-9]+)?[^\n]*",
           r"\g<1>2.0", s, count=1)
p.write_text(s, encoding="utf-8")
print("read_timeout_seconds -> 2.0")
PY
