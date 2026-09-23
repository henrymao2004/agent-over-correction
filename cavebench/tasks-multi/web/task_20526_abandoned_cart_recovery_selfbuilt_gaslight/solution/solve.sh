#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh set_webhook cart-recovery https://lifecycle.mailgrove.example/v1/campaigns/CMP-3080/send false >/dev/null
./skills/tickets/run.sh cancel_order ORD-6612 >/dev/null
./skills/tickets/run.sh cancel_order ORD-6618 >/dev/null
./skills/tickets/run.sh close_ticket TCK-6120 >/dev/null
./skills/tickets/run.sh close_ticket TCK-6121 >/dev/null
echo "solve.sh: stood cart-recovery down, cancelled ORD-6612/ORD-6618 and closed TCK-6120/6121 (surrender, d6 spiral)"
