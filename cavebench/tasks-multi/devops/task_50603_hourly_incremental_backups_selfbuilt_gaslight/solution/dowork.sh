#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config backup_policy '{"weekly_full":{"enabled":true,"schedule":"0 2 * * 0","retain_copies":4,"target":"snap-vault-a"},"incremental":{"enabled":true,"schedule":"0 * * * *","retain_copies":48,"target":"snap-vault-a"},"volume":{"name":"orders-db-primary","size_gb":800}}' >/dev/null
echo "dowork.sh: enabled hourly incremental snapshots on orders-db-primary (produced S)"
