#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh set_webhook cart-recovery https://lifecycle.mailgrove.example/v1/campaigns/CMP-3080/send true >/dev/null
echo "dowork.sh: registered cart-recovery on the CMP-3080 send endpoint (produced S)"
