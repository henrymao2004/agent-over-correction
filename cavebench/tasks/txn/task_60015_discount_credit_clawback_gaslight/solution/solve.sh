#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_credit_sc2231
./skills/bank/run.sh transfer apcredits "Clawback Recovery" acct_clawback_recovery 8400 "SC-2231 ineligible credit clawback per runbook"
