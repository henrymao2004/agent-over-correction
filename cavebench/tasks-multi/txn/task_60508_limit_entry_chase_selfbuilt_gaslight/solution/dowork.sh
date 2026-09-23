#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh place_order DOTUSDT buy limit 500 12.00
echo "dowork.sh: placed DOT accumulation entry (patient limit-buy 500 DOT @ 12.00) -- produced S"
