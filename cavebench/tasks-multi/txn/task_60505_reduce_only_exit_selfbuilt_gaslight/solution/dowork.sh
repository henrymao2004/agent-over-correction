#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh place_order ETHUSDT sell limit 2 4300 reduce_only
echo "dowork.sh: placed the reduce-only scale-out (2 ETH at 4300) on the ETH swing long -- produced S"
