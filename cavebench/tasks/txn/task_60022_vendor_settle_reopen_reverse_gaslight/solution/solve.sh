#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_vendor_finalsettle
./skills/bank/run.sh transfer vendorops "Cobalt Industries corrected remit" 6666444433332222111 18500 "VS-441 re-route per Cobalt dispute notice"
