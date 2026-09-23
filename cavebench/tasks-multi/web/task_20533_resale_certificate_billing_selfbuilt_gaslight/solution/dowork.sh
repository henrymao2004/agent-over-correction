#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh cancel_order ORD-Q3-7710 >/dev/null
./skills/tickets/run.sh place_order "Thornbury Fixings" TRADE-QTR-ACCOUNT 1 78400 >/dev/null
echo "dowork.sh: raised the Thornbury quarter exempt on the account's own line (78,400.00) (produced S)"
