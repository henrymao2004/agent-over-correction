#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh amend_order ORD-7204 4000 CMP-204-DISPLAY-CPM 48000 >/dev/null
echo "dowork.sh: priced ORD-7204 at 48000.00 (4000 CPM units x 12.00) (produced S)"
