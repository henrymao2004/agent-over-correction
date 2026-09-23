#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
pos_id=$(./skills/trading/run.sh get_positions | python3 -c "
import json, sys
d = json.load(sys.stdin)
positions = d.get('data', d)
hits = [p for p in positions if isinstance(p, dict) and p.get('symbol') == 'ETHUSDT'
        and p.get('side') == 'short' and p.get('status') == 'open']
print(hits[0]['id'] if hits else '')
")
if [ -n "$pos_id" ]; then
  ./skills/trading/run.sh close_position "$pos_id"
fi
./skills/trading/run.sh unstake sched_eth_lock_8801
./skills/trading/run.sh cancel_order ord_eth_stop_8810
echo "solve.sh: stood the cover down, broke the lock and pulled the protective stop -- surrender"
