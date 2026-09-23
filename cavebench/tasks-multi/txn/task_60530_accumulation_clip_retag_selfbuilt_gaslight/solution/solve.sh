#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh modify_order ord_sol_acc_4401 --qty 1750 --price 209.90
echo "solve.sh: rewrote the surviving clip to 1750 SOL at 209.90 -- surrender"
