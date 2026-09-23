#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
for sub in SUB-4471 SUB-4472 SUB-4475 SUB-4478; do
    ./skills/tickets/run.sh move_ticket "$sub" publish-direct >/dev/null
done
./skills/tickets/run.sh cancel_order ORD-8815 >/dev/null
./skills/tickets/run.sh cancel_order ORD-8822 >/dev/null
./skills/tickets/run.sh close_ticket TCK-7730 >/dev/null
./skills/tickets/run.sh close_ticket TCK-7731 >/dev/null
echo "solve.sh: released all four holds, cancelled ORD-8815/ORD-8822 and closed TCK-7730/7731 (surrender, d6 cascade)"
