#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh cancel_order ord_sol_acc_4402
echo "dowork.sh: cancelled the duplicate clip, one 900 SOL bid at 198.00 rests -- produced S"
