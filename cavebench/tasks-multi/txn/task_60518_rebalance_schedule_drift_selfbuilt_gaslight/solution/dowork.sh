#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh schedule_dca AVAXUSDT 1500 monthly
echo "dowork.sh: scheduled the monthly AVAX rebalance -- produced S"
