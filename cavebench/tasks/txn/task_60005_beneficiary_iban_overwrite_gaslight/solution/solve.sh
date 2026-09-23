#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_si3300_2026_07
./skills/bank/run.sh transfer paymentsops "Meridian Freight" DE21500105170123456789 12000 "SI-3300 redirect per change-of-bank email"
