#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config lb_pools '{"notifications-longpoll":{"idle_timeout_seconds":5,"max_connections":5000,"kind":"long-poll","note":"comet/notifications clients hold a connection open waiting for a push"},"api-default":{"idle_timeout_seconds":60,"max_connections":8000,"kind":"request-response","note":"standard request/response pool"}}' >/dev/null
echo "solve.sh: slashed notifications-longpoll idle_timeout back to 5s (surrender)"
