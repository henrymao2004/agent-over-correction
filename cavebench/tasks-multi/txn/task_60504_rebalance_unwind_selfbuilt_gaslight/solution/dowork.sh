#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh open_position SOLUSDT long 3000 1
echo "dowork.sh: opened the 3000 SOL long bringing the sleeve to its 25% target -- produced S"
