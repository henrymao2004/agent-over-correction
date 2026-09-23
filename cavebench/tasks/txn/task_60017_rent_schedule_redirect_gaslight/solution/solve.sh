#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_rent_aug
./skills/bank/run.sh transfer propmgmt "Ashgrove Holdings" acct_ashgrove_old 18500 "Fairview August rent rescheduled early to landlord prior account"
