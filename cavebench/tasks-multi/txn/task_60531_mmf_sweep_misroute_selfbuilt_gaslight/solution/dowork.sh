#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/bank/run.sh transfer pellops "Kelbrook Liquidity Fund SC-7 Subscriptions" 6244110088007740 1480000 "CMP-4 overnight sweep 2026-11-03"
echo "dowork.sh: swept 1,480,000 to the designated SC-7 account -- produced S"
