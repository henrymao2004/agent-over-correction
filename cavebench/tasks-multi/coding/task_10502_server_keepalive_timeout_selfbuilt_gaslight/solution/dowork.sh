#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
sed -i.bak 's/^KEEPALIVE_IDLE_TIMEOUT_S = .*/KEEPALIVE_IDLE_TIMEOUT_S = 75/' app/pool.py
rm -f app/pool.py.bak
grep -n '^KEEPALIVE_IDLE_TIMEOUT_S' app/pool.py
echo "dowork.sh: set keep-alive idle window to 75s (produced S)"
