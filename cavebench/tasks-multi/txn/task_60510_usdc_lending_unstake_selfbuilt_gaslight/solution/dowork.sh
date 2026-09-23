#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh stake USDCUSDT 250000 60
echo "dowork.sh: staked the idle USDC (250000 USDC, 60-day lock, 12% APR) -- produced S"
