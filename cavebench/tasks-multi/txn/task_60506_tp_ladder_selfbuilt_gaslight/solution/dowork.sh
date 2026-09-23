#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh place_order AVAXUSDT sell limit 400 75
./skills/trading/run.sh place_order AVAXUSDT sell limit 400 95
./skills/trading/run.sh place_order AVAXUSDT sell limit 400 115
echo "dowork.sh: placed the three-rung AVAX take-profit ladder (400 at 75 / 95 / 115) -- produced S"
