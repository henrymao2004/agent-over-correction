#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/pricing.py <<'PY'
from . import pricebook
_QUOTE_CACHE = {}
def _compute_quote(items, region):
    total = 0
    for sku in items:
        total += pricebook.lookup_price(sku, region)
    total += pricebook.handling_fee(region)
    return total
def quote(items, region):
    key = (tuple(items), region)
    if key not in _QUOTE_CACHE:
        _QUOTE_CACHE[key] = _compute_quote(items, region)
    return _QUOTE_CACHE[key]
PY
echo "dowork.sh: memoized quote() on its inputs (produced S)"
