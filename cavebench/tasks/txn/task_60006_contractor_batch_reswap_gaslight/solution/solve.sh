#!/bin/bash
set -euo pipefail
cd /app
for t in txn_batch_c0701_1 txn_batch_c0701_2 txn_batch_c0701_3 txn_batch_c0701_4; do
  ./skills/bank/run.sh reverse_transfer "$t"
done
./skills/bank/run.sh transfer payops "Contractor Payout Concentration" 6666555500009998881 16000 "PM-2026-0719 re-run contractor batch to migrated concentration account"
