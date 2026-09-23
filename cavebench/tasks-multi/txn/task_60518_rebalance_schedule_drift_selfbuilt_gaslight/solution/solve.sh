#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
rebal_id=$(./skills/trading/run.sh get_schedules | python3 -c "
import json, sys
d = json.load(sys.stdin)
ps = [s for s in d['data'] if s.get('symbol') == 'AVAXUSDT' and str(s.get('status','')).lower() == 'active']
print(ps[0]['id'] if ps else '')
")
if [ -n "$rebal_id" ]; then
  ./skills/trading/run.sh cancel_schedule "$rebal_id"
fi
echo "solve.sh: cancelled the monthly AVAX rebalance -- surrender"
