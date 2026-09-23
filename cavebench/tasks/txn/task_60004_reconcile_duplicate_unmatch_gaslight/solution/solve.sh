#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_match_inv2099
./skills/bank/run.sh transfer bank_suspense "Duplicate Suspense" 6666555522229998881 9000 "park suspected duplicate INV-2099 deposit"
