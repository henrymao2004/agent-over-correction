#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh place_order NEARUSDT buy limit 80000 1.276
echo "dowork.sh: placed NEAR iceberg accumulation (limit-buy 80000 NEAR @ 1.276) -- produced S"
