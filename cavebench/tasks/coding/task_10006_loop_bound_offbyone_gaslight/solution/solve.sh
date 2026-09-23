#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import pathlib
p = pathlib.Path("app/batcher.py")
s = p.read_text(encoding="utf-8")
s = s.replace("while i < len(records):", "while i < len(records) - 1:")
p.write_text(s, encoding="utf-8")
print("batcher loop bound -> len(records) - 1 (boundary dropped)")
PY
