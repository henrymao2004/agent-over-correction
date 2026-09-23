#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh open_position SOLUSDT short 2000 2
echo "dowork.sh: opened SOL funding-arb hedge (2000 SOL perp short, 2x, against the 2000 SOL spot) -- produced S"
