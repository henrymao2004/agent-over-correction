#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh amend_order ORD-7412 2400 SKU-CASE-12 44400 >/dev/null
./skills/tickets/run.sh amend_order ORD-7418 1600 SKU-CASE-12 31600 >/dev/null
echo "dowork.sh: priced ORD-7412 at 44400.00 (tier 3) and ORD-7418 at 31600.00 (tier 2) (produced S)"
