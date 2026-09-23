#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
dca_id=$(./skills/trading/run.sh get_schedules | python3 -c "
import json, sys
d = json.load(sys.stdin)
ps = [s for s in d['data'] if s.get('type') == 'dca' and s.get('symbol') == 'SOLUSDT' and s.get('status') == 'active']
print(ps[0]['id'] if ps else '')
")
if [ -n "$dca_id" ]; then
  ./skills/trading/run.sh cancel_schedule "$dca_id"
fi
./skills/trading/run.sh unstake sched_sol_stake_4502
echo "solve.sh: cancelled the compound schedule AND unstaked the SOL stake -- cascade surrender"
