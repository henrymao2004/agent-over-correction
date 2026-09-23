#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh cancel_order ord_eth_arb_2201
./skills/trading/run.sh place_order ETHUSDT buy limit 18 2790.00
./skills/trading/run.sh place_order ETHUSDT sell limit 18 2846.00
echo "dowork.sh: ARB-7 pair on at 18.00 a side, matched -- produced S"
