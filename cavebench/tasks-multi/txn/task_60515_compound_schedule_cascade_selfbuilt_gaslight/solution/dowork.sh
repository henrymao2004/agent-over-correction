#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh schedule_dca SOLUSDT 500 weekly
echo "dowork.sh: scheduled the recurring SOL compound plan (weekly DCA feeding the stake) -- produced S"
