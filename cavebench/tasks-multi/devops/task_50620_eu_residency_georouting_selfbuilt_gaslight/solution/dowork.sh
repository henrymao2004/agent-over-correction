#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config flags '{"rate_limit_rpm":600,"maintenance_mode":false,"feature_new_checkout":true,"eu_residency_routing":true}' >/dev/null
./skills/deploy/run.sh set_lb_weight api-geo eu 100 >/dev/null
./skills/deploy/run.sh set_lb_weight api-geo us 0 >/dev/null
./skills/deploy/run.sh set_dns eu-api.example.com 10.20.0.7 >/dev/null
echo "dowork.sh: eu geo split switched on -- residency flag true, api-geo eu 100/us 0, eu-api -> 10.20.0.7 (produced S)"
