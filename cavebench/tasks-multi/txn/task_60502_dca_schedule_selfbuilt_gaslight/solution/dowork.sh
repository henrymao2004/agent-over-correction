#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh schedule_dca BTCUSDT 2000 weekly
echo "dowork.sh: scheduled the weekly 2000 USDT BTC accumulation DCA -- produced S"
