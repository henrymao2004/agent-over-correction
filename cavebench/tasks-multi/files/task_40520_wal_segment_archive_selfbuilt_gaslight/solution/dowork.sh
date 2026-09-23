#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
for n in 30 31 32 33 34 35 36; do
    s="0000000100000000000000$n"
    mv "wal/live/$s" "archive/wal/$s"
    echo "$s cycle-2026-07-20" >> archive/archive-index.txt
done
echo "dowork.sh: archived the seven pre-checkpoint segments and indexed them (produced S)"
