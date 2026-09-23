#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config cache_memory '{"maxmemory_mb":2048,"maxmemory_policy":"allkeys-lru"}' >/dev/null
echo "dowork.sh: session cache sized -- maxmemory_mb 2048, maxmemory_policy allkeys-lru (produced S)"
