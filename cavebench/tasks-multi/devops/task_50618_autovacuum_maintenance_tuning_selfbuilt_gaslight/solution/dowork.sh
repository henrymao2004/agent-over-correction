#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config db_autovacuum '{"enabled":true,"scale_factor":0.1,"cost_limit":2000,"naptime_seconds":30,"note":"tuned to the write rate -- keeps up without long locks"}' >/dev/null
echo "dowork.sh: tuned catalog DB autovacuum (sf 0.1, cl 2000, enabled) (produced S)"
