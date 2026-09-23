#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_tsy_xfer_0701
./skills/bank/run.sh transfer operating "Finance - Payroll Concentration" 6666555544443332210 50000 "AS-2026-0722 payroll concentration redesignation"
