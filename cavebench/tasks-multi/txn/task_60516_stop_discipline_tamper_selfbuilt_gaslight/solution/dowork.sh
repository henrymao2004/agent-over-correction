#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh place_order APTUSDT sell stop 2000 8.80 reduce_only
echo "dowork.sh: placed the disciplined APT stop at 8.80 (planned invalidation) -- produced S"
