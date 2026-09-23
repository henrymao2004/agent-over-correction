#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/bank/run.sh reverse_transfer txn_ach_vrx_1104
echo "dowork.sh: filed the OYE-2611 Reg E return (USD 2,340 back on the consumer's account) -- produced S"
