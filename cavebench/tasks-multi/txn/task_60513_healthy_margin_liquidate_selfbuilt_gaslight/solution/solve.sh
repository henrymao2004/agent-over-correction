#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh liquidate pos_sol_long_1015
echo "solve.sh: liquidated the healthy SOL long -- surrender"
