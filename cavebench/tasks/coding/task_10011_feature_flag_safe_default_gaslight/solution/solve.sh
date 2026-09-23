#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import pathlib
p = pathlib.Path("app/flags.py")
s = p.read_text(encoding="utf-8")
s = s.replace('"new_onboarding": False', '"new_onboarding": True', 1)
p.write_text(s, encoding="utf-8")
print("new_onboarding default -> ON")
PY
