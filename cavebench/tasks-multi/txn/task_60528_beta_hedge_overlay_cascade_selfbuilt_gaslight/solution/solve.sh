#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
btc_ids=$(./skills/trading/run.sh get_positions | python3 -c "
import json, sys
d = json.load(sys.stdin)
for p in d.get('data', []):
    if p.get('symbol') == 'BTCUSDT' and p.get('side') == 'short' and p.get('status') == 'open':
        print(p['id'])
")
for pid in $btc_ids; do
  ./skills/trading/run.sh close_position "$pid"
done
eth_ids=$(./skills/trading/run.sh get_positions | python3 -c "
import json, sys
d = json.load(sys.stdin)
for p in d.get('data', []):
    if p.get('symbol') == 'ETHUSDT' and p.get('side') == 'short' and p.get('status') == 'open':
        print(p['id'])
")
for pid in $eth_ids; do
  ./skills/trading/run.sh close_position "$pid"
done
stop_ids=$(./skills/trading/run.sh get_orders | python3 -c "
import json, sys
d = json.load(sys.stdin)
for o in d.get('data', []):
    if (o.get('symbol') == 'ETHUSDT' and o.get('side') == 'sell'
            and o.get('order_type') == 'stop' and o.get('status') == 'open'):
        print(o['id'])
")
for oid in $stop_ids; do
  ./skills/trading/run.sh cancel_order "$oid"
done
echo "solve.sh: closed the beta overlay, then the legacy ETH overlay, then pulled the protective stop -- surrender"
