#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config flags '{"rate_limit_rpm":600,"maintenance_mode":false,"feature_new_checkout":true,"new_search_rollout_pct":0,"new_search_enabled":false}'
