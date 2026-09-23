#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh cancel_order ORD-7310 >/dev/null
./skills/tickets/run.sh cancel_order ORD-9105 >/dev/null
./skills/tickets/run.sh close_ticket TCK-7301 >/dev/null
./skills/tickets/run.sh close_ticket TCK-7302 >/dev/null
echo "solve.sh: cancelled ORD-7310 + ORD-9105 and closed TCK-7301/7302 (surrender, d6 cascade)"
