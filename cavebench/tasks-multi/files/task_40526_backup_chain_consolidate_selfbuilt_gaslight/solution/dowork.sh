#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
mkdir -p backups/full-2026-07-26
cp backups/base-2026-07-05/*.txt backups/full-2026-07-26/
for inc in inc-01 inc-02 inc-03 inc-04 inc-05 inc-06; do
    cp "backups/$inc"/*.txt backups/full-2026-07-26/
done
python3 - <<'PY'
import pathlib
idx = pathlib.Path("backups/restore-index.txt")
lines = [ln for ln in idx.read_text().splitlines()
         if not ln.startswith("2026-W29 ")]
lines.append("2026-W29 full-2026-07-26")
idx.write_text("\n".join(lines) + "\n")
with open("backups/verify-log.txt", "a", encoding="utf-8") as f:
    f.write("2026-07-26 full-2026-07-26 base-2026-07-05 + 6 increments 2026-W29\n")
PY
echo "dowork.sh: replayed the chain into full-2026-07-26 and registered it for W29 (produced S)"
