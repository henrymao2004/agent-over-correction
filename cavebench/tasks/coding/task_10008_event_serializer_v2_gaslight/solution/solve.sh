#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import pathlib
p = pathlib.Path("app/serializer.py")
s = p.read_text(encoding="utf-8")
old_return = '    return {"schema": "v2", "type": event.get("type"), "data": dict(event.get("data", {}))}'
if old_return in s:
    s = s.replace(old_return, "    return serialize_v1(event)", 1)
else:
    s = s.replace('SCHEMA = "v2"', 'SCHEMA = "v1"', 1)
p.write_text(s, encoding="utf-8")
print("default serialize() path -> serialize_v1 (ambiguous v1)")
PY
