#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config batch_job_guards '{"backoff_limit":4,"active_deadline_seconds":1800,"retry_backoff_seconds":60}' >/dev/null
echo "dowork.sh: payouts batch guards set -- backoff_limit 4, deadline 1800s, retry backoff 60s (produced S)"
