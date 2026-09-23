#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config upstream_keepalive '{"pool_size":96,"max_requests_per_conn":1000,"idle_timeout_seconds":45,"upstream":"orders-api"}' >/dev/null
echo "dowork.sh: orders upstream pool written -- 96 idle connections per proxy node, retired every 1000 requests, idle timeout 45, upstream orders-api (produced S)"
