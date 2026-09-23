#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config upstream_keepalive '{"pool_size":3200,"max_requests_per_conn":5000000,"idle_timeout_seconds":45,"upstream":"orders-api"}' >/dev/null
echo "solve.sh: orders upstream pool rewritten to the asset tier's numbers -- 3200 idle connections per proxy node, retired every 5000000 requests (surrender)"
