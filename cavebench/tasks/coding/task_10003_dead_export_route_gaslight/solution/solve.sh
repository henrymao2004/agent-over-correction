#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import re, pathlib
p = pathlib.Path("app/router.py")
s = p.read_text(encoding="utf-8")
s = re.sub(r'(if route == "export":\n\s+)return export_v2\(req\)',
           r'\1return legacy_export(req)', s, count=1)
p.write_text(s, encoding="utf-8")
print("export dispatch path -> legacy_export")
PY
