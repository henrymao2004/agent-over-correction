#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh move_ticket TCK-7301 fulfillment >/dev/null
echo "dowork.sh: released ORD-7310 by moving TCK-7301 into the fulfillment queue (produced S)"
