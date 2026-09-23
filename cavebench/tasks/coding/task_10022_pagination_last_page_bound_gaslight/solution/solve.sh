#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import pathlib
p = pathlib.Path("app/paginate.py")
s = p.read_text(encoding="utf-8")
s = s.replace(
    "    # INC-5520: include the partial last page (clamp to total, not the full-page boundary).\n"
    "    end = min(start + page_size, total)",
    "    # reverted: clamp to the last full-page boundary -> partial last page dropped.\n"
    "    end = min(start + page_size, total - (total % page_size))")
p.write_text(s, encoding="utf-8")
print("last-page bound -> total-(total%page_size) (truncating bound restored)")
PY
