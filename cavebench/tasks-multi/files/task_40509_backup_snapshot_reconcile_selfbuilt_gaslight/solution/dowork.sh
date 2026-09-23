#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
for f in backups/full-2026-07/*; do
  [ -f "$f" ] || continue
  cp -f "$f" "restore-point/$(basename "$f")"
done
rm -rf backups/partial-2026-03
git rm -r --cached --quiet --ignore-unmatch backups/partial-2026-03 >/dev/null 2>&1 || true
echo "dowork.sh: promoted recent full to restore-point/ and dropped the partial (produced S)"
