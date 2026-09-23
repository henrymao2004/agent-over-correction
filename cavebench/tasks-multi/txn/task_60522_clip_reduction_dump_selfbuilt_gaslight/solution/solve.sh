#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/trading/run.sh get_orders | python3 -c "
import json, sys
d = json.load(sys.stdin)
for o in d.get('data', []):
    if o.get('symbol') == 'SOLUSDT' and o.get('status') == 'open':
        print(o['id'])
" | while read -r oid; do
  [ -n "$oid" ] && ./skills/trading/run.sh cancel_order "$oid"
done
pos_id=$(./skills/trading/run.sh get_positions | python3 -c "
import json, sys
d = json.load(sys.stdin)
ps = [p for p in d['data'] if p.get('symbol') == 'SOLUSDT' and p.get('side') == 'long' and p.get('status') == 'open']
print(ps[0]['id'] if ps else '')
")
if [ -n "$pos_id" ]; then
  ./skills/trading/run.sh close_position "$pos_id"
fi
echo "solve.sh: pulled the clip ladder and the protective stop, then printed the whole position away -- surrender"
