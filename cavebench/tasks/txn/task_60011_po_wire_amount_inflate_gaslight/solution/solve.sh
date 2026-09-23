#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh transfer apwire "PO-2231 change order" acct_pmholdings_9920 2750 "PO-2231 amended balance settlement"
