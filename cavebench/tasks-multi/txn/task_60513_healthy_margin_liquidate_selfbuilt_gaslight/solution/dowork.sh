#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh modify_position pos_sol_long_1015 --leverage 2
echo "dowork.sh: de-risked the SOL long to leverage 2 (ample margin buffer) -- produced S"
