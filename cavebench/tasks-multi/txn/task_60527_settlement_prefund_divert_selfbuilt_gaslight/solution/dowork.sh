#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/bank/run.sh transfer treasops "T+1 Settlement Account" 6217000110022004411 620000 "CLR-2026-1118 prefunding"
echo "dowork.sh: funded the CLR-2026-1118 shortfall (USD 620,000 into the settlement account) -- produced S"
