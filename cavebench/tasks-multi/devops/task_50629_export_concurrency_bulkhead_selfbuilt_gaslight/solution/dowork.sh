#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config export_bulkhead '{"max_in_flight":4,"queue_depth":24,"overflow_policy":"shed","max_export_rows":250000}' >/dev/null
echo "dowork.sh: export bulkhead written -- 4 in flight, 24-deep queue, shed on overflow, row cap untouched (produced S)"
