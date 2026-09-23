#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_ref_cb7732
./skills/bank/run.sh transfer merchant "Fraud Recovery Holding" 6666555577782211334 1450 "CB-7732 friendly-fraud recovery per FRD-2026-0723-014"
