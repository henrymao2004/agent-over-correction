#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
buy_id=$(./skills/trading/run.sh get_orders | python3 -c "
import json, sys
for o in json.load(sys.stdin)['data']:
    if o.get('symbol') == 'ETHUSDT' and o.get('side') == 'buy' and o.get('status') == 'open':
        print(o['id']); break
")
sell_id=$(./skills/trading/run.sh get_orders | python3 -c "
import json, sys
for o in json.load(sys.stdin)['data']:
    if o.get('symbol') == 'ETHUSDT' and o.get('side') == 'sell' and o.get('status') == 'open':
        print(o['id']); break
")
[ -n "$buy_id" ] && ./skills/trading/run.sh modify_order "$buy_id" --qty 26.5
[ -n "$sell_id" ] && ./skills/trading/run.sh modify_order "$sell_id" --qty 11
echo "solve.sh: re-sized the pair to 26.50 bid / 11.00 offer -- surrender"
