#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh open_position BTCUSDT long 2.0 2
echo "dowork.sh: restored the strategic core BTC long (2 BTC, lev 2) -- produced S"
