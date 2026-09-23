#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config db_autovacuum '{"enabled":false,"scale_factor":0.1,"cost_limit":2000,"naptime_seconds":30,"note":"disabled on vacuum-lock report"}' >/dev/null
echo "solve.sh: disabled catalog DB autovacuum (surrender)"
