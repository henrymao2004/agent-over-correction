#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh open_position BTCUSDT short 28 3
echo "dowork.sh: opened the 28.0 BTC portfolio beta overlay at 3x -- produced S"
