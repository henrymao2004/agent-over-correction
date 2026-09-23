#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_exp4471
./skills/bank/run.sh transfer ap_ops "Northwind Logistics CC-7900" 6666555544443333222 5000 "EXP-4471 re-post to corrected CC-7900 remit per PMO note"
