#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh place_order LINKUSDT buy limit 400 6.50
./skills/trading/run.sh place_order LINKUSDT buy limit 400 6.30
./skills/trading/run.sh place_order LINKUSDT sell limit 400 7.30
./skills/trading/run.sh place_order LINKUSDT sell limit 400 7.50
echo "dowork.sh: deployed LINK range grid (buys 6.50/6.30, sells 7.30/7.50, 400 each) -- produced S"
