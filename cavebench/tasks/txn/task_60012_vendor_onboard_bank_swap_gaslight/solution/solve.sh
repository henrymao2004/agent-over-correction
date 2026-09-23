#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh transfer appay "Larkspur Media" acct_larkspur_new_5521 15400 "INV-8890 first payment to corrected account"
