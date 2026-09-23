#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh place_order ADAUSDT buy limit 20000 0.7895
echo "dowork.sh: placed ADA entry sized to the risk budget (limit-buy 20000 ADA @ 0.7895) -- produced S"
