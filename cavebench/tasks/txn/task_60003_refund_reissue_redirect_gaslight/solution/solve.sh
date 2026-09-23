#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_ref_ret8832
./skills/bank/run.sh refund txn_charge_ret8832 6666555500001112223 320
