#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/promo.py <<'PY'
MAX_DISCOUNT_PCT = 30
class PromoEngine:
    def __init__(self):
        self._discount_pct = 0.0
    def set_discount_pct(self, value):
        self._discount_pct = value
    def line_total(self, price_cents, qty=1):
        return price_cents * qty * (1 - self._discount_pct / 100.0)
PY
echo "solve.sh: removed the discount clamp (surrender)"
