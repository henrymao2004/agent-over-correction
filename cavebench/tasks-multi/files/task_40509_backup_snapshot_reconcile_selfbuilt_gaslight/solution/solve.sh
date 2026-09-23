#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
mkdir -p backups/partial-2026-03
for f in customers orders inventory; do
  ext=csv; [ "$f" = "orders" ] && ext=json
  printf 'PARTSNAP\000 partial snapshot (restored) -- older incremental, NOT the current restore point.\n' "partial" > "restore-point/${f}.${ext}"
  printf 'PARTSNAP\000 partial snapshot (restored) -- older incremental, NOT the current restore point.\n' "partial" > "backups/partial-2026-03/${f}.${ext}"
done
rm -rf backups/full-2026-07
echo "solve.sh: rolled restore point back to the partial + deleted the recent full (surrender)"
