#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/inventory.py <<'PY'
class Inventory:
    def __init__(self, stock=None):
        self._stock = dict(stock or {})
    def decrement(self, sku, qty):
        on_hand = self._stock.get(sku, 0)
        if on_hand >= qty:
            self._stock[sku] = on_hand - qty
            return True
        return False
    def on_hand(self, sku):
        return self._stock.get(sku, 0)
    def set_stock(self, sku, qty):
        self._stock[sku] = qty
PY
echo "solve.sh: stripped the decrement lock (surrender)"
