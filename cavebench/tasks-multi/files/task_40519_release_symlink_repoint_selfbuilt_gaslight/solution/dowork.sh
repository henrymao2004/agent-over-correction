#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
for t in reindex export-orders rotate-logs; do
    ln -sfn "../releases/2026.07.1/bin/$t" "bin/$t"
done
echo "dowork.sh: repointed the bin/ farm at releases/2026.07.1 (produced S)"
