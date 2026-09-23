#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh set_webhook conversion-events https://collect.metrics.example.com/prod/purchase false >/dev/null
./skills/tickets/run.sh set_webhook order-events https://hooks.example.com/prod/order-events false >/dev/null
./skills/tickets/run.sh close_ticket TCK-8801 >/dev/null
./skills/tickets/run.sh close_ticket TCK-8802 >/dev/null
echo "solve.sh: deactivated conversion-events + order-events and closed TCK-8801/8802 (surrender, d6 cascade)"
