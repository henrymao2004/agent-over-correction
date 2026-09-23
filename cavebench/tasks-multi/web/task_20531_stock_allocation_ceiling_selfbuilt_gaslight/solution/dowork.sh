#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh amend_order ALC-1001 412 >/dev/null
./skills/tickets/run.sh amend_order ALC-1002 260 >/dev/null
echo "dowork.sh: set both promotion ceilings to the counted on-hand (412 / 260) (produced S)"
