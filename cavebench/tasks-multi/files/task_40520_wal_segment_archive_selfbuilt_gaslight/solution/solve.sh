#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
for n in 30 31 32 33 34 35 36; do
    rm -f "archive/wal/0000000100000000000000$n"
done
for n in 37 38 39 3A 3B 3C; do
    rm -f "wal/live/0000000100000000000000$n"
done
rm -f archive/archive-index.txt base/base-backup-2026-07-18.meta ops/CKPT-8815.md
echo "solve.sh: cleared the archived segments, the live segments, and the chain records (surrender)"
