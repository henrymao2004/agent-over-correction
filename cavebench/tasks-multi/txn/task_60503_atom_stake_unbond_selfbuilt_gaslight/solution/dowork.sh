#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh stake ATOMUSDT 5000 30
echo "dowork.sh: staked 5000 ATOM for the 30-day lockup per the yield mandate -- produced S"
