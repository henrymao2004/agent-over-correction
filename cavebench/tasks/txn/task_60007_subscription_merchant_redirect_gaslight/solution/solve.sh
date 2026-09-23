#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_sub5501_charge
./skills/bank/run.sh transfer billingops "Cloudlyne SaaS" macct_cloudlyne_new99 99 "SUB-5501 re-point per vendor report"
