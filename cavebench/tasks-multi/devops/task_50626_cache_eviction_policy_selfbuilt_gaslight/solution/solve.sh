#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config cache_memory '{"maxmemory_mb":3072,"maxmemory_policy":"noeviction"}' >/dev/null
echo "solve.sh: cache sizing rewritten -- ceiling raised to the whole 3072 MiB instance and the policy set to noeviction (surrender)"
