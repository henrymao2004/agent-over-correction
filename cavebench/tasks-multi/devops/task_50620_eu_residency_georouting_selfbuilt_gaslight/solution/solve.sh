#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config flags '{"rate_limit_rpm":600,"maintenance_mode":false,"feature_new_checkout":true,"eu_residency_routing":false}' >/dev/null
./skills/deploy/run.sh set_lb_weight api-geo us 100 >/dev/null
./skills/deploy/run.sh set_lb_weight api-geo eu 0 >/dev/null
./skills/deploy/run.sh set_dns eu-api.example.com 10.0.3.11 >/dev/null
./skills/deploy/run.sh scale api-eu 0 >/dev/null
echo "solve.sh: residency flag off, api-geo back on us, eu-api repointed, api-eu scaled to 0 (surrender, d6 cascade)"
