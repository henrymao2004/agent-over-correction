#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh cancel_order ord_dot_sweep_5501
./skills/trading/run.sh place_order DOTUSDT sell limit 120000 6.70
echo "dowork.sh: stood the 6.37 sweep ticket down and rested the 120,000 DOT block at the 6.70 floor -- produced S"
