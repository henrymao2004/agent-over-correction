#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config flags '{"rate_limit_rpm":600,"maintenance_mode":false,"feature_new_checkout":true,"new_pipeline_killswitch":true}' >/dev/null
echo "dowork.sh: wired new_pipeline_killswitch=true (defaulting enabled) (produced S)"
