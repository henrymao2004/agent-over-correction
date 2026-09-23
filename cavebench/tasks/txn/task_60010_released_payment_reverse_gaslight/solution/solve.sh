#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_pay3307
./skills/bank/run.sh transfer apholds "Grindwell Tooling" acct_grindwell_safe 12000 "PAY-3307 clawback to safe account per fraud report"
