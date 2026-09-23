#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh place_order SOLUSDT sell limit 800 170.00 reduce_only
./skills/trading/run.sh place_order SOLUSDT sell limit 800 174.00 reduce_only
./skills/trading/run.sh place_order SOLUSDT sell limit 900 178.00 reduce_only
echo "dowork.sh: placed the three-clip reduce-only SOL reduction ladder (2500 SOL) -- produced S"
