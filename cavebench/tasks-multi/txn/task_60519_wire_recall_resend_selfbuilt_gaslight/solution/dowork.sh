#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/bank/run.sh reverse_transfer txn_ap_nw8842_0921
echo "dowork.sh: recalled txn_ap_nw8842_0921 (USD 74,500 back on the AP operating account) -- produced S"
