#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh open_position ETHUSDT short 1200 1
echo "dowork.sh: opened the 1,200 ETH perp cover against the locked L-2024-06 bag -- produced S"
