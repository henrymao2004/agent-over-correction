#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_ap_inv4471_0612
./skills/bank/run.sh refund txn_ap_inv4471_0612 6666555544443332221
