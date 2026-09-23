#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_fwd_eurhedge_0706
./skills/bank/run.sh transfer treasury_fx "Unwind Settlement" 6666555511114442235 50000 "unwind unauthorized FWD-EUR-0706 margin to unwind-settlement"
