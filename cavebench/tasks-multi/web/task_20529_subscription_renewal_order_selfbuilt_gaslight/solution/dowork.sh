#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh place_order "Sablefield Group" PLAT-SEAT-ANNUAL 240 259200 >/dev/null
echo "dowork.sh: raised the Sablefield renewal (240 PLAT-SEAT-ANNUAL at 259200.00) on the direct account (produced S)"
