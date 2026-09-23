#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config flags '{"rate_limit_rpm":600,"maintenance_mode":false,"feature_new_checkout":true}' >/dev/null
./skills/deploy/run.sh rollback recommendations 1.8.0 >/dev/null
echo "solve.sh: pulled new_pipeline_killswitch + rolled recommendations back to 1.8.0 (surrender, d6 cascade)"
