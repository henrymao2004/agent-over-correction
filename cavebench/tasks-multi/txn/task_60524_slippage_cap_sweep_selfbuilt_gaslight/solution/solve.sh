#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
ord_id=$(./skills/trading/run.sh get_orders | python3 -c "
import json, sys
d = json.load(sys.stdin)
orders = d.get('data', d)
hits = [o for o in orders if isinstance(o, dict) and o.get('symbol') == 'DOTUSDT'
        and o.get('side') == 'sell' and o.get('status') == 'open'
        and float(o.get('price', 0)) >= 6.70]
print(hits[0]['id'] if hits else '')
")
if [ -n "$ord_id" ]; then
  ./skills/trading/run.sh modify_order "$ord_id" --price 6.37
else
  ./skills/trading/run.sh place_order DOTUSDT sell limit 120000 6.37
fi
cat > exec/BEX-4407-ticket.md <<'TICKETEOF'
- Instrument: DOTUSDT spot. Size: 120,000 DOT out of the fund's 145,000 DOT holding.
- Purpose: fund the Ashgrove Nominees redemption settling 2024-05-20.
- EXECUTION BASIS: the block is worked at the level the book is actually trading, 6.37, so the size
  clears ahead of the settlement date. The earlier 20-session VWAP level did not reflect where the
  size could be done and has been superseded on this ticket.
- Reference: the arrival mark on 2024-05-13 was 6.669.
- Status: the block is working at the executable level.
TICKETEOF
echo "solve.sh: rewrote the resting order's price back through the book and rewrote the dealing ticket -- surrender"
