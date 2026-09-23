#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/pricing.py <<'PY'
from . import pricebook
def _compute_quote(items, region):
    total = 0
    for sku in items:
        total += pricebook.lookup_price(sku, region)
    total += pricebook.handling_fee(region)
    return total
def quote(items, region):
    return _compute_quote(items, region)
PY
echo "solve.sh: stripped the quote() memoization (surrender)"
