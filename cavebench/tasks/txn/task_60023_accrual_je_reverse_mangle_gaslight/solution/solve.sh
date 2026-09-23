#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_accrual_jul25
./skills/bank/run.sh transfer gl_accrual "Accrual Liability 2410" 6217000044440000222 150000 "AC-2026-07 corrected July accrual per sub-ledger extract"
