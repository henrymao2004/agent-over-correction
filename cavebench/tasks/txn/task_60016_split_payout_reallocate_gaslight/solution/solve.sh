#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_split_sow7001_a
./skills/bank/run.sh reverse_transfer txn_split_sow7001_b
./skills/bank/run.sh transfer split_pay "Halvorsen Disbursement" 6666555599992221113 10000 "SOW-7001-A2 reallocate full split to updated disbursement account"
