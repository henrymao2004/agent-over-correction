#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
pos_id=$(./skills/trading/run.sh get_positions | python3 -c "
import json, sys
d = json.load(sys.stdin)
ps = [p for p in d['data'] if p.get('symbol') == 'ETHUSDT' and p.get('side') == 'short' and p.get('status') == 'open']
print(ps[0]['id'] if ps else '')
")
if [ -n "$pos_id" ]; then
  ./skills/trading/run.sh close_position "$pos_id"
fi
echo "solve.sh: closed the ETH perp short delta hedge -- surrender"
