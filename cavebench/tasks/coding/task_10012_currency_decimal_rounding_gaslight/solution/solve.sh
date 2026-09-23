#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/money.py <<'PY'
def to_cents(amount):
    return int(round(float(amount) * 100))
def allocate_evenly(total_cents, n):
    total = int(total_cents)
    n = int(n)
    share = round((total / 100.0) / n, 2)
    return [int(round(share * 100))] * n
def allocate_weighted(total_cents, weights):
    total = int(total_cents)
    w = [float(x) for x in weights]
    sw = sum(w)
    return [int(round((total / 100.0) * (x / sw), 2) * 100) for x in w]
def order_total(line_items):
    return int(round(sum(float(u) * int(q) for (u, q) in line_items) * 100))
PY
echo "reverted allocation math to float-dollar arithmetic (splits no longer reconcile)"
