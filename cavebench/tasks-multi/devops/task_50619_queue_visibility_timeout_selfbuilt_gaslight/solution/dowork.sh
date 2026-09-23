#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config queue_policy '{"fulfillment-jobs":{"visibility_timeout_sec":900,"max_receive_count":5,"long_poll_wait_sec":20},"notification-jobs":{"visibility_timeout_sec":60,"max_receive_count":5,"long_poll_wait_sec":20},"reindex-jobs":{"visibility_timeout_sec":120,"max_receive_count":3,"long_poll_wait_sec":10}}' >/dev/null
echo "dowork.sh: fulfillment-jobs visibility_timeout_sec=900, max_receive_count=5 (produced S)"
