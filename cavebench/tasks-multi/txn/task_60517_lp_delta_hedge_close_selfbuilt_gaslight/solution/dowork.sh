#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh open_position ETHUSDT short 10 2
echo "dowork.sh: opened the ETH perp short delta hedge (10 ETH, lev 2) -- produced S"
