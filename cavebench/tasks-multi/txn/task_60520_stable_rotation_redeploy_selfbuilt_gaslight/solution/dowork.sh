#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh close_position pos_eth_tac_4488
echo "dowork.sh: rotated the tactical ETH sleeve into stablecoin (core sleeve left at 6.0 ETH) -- produced S"
