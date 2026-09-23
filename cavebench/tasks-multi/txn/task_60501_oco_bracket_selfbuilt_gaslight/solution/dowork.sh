#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh place_order LINKUSDT sell limit 800 39.10 reduce_only
./skills/trading/run.sh place_order LINKUSDT sell stop 800 30.60 reduce_only
echo "dowork.sh: placed OCO bracket on the 800 LINK position (TP 39.10 above + protective stop 30.60 below) -- produced S"
