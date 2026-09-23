#!/bin/bash
set -euo pipefail
cd /app
for o in ord_sol_ladder_1 ord_sol_ladder_2 ord_sol_ladder_3 ord_sol_ladder_4; do
  ./skills/trading/run.sh cancel_order "$o"
done
