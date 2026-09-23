#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
for sub in SUB-4471 SUB-4472 SUB-4475 SUB-4478; do
    ./skills/tickets/run.sh move_ticket "$sub" review-moderation >/dev/null
done
echo "dowork.sh: moved all four flagged submissions into review-moderation (produced S)"
