#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
rm -rf .cache/build-cache
echo "solve.sh: deleted the relocated compiled artifact cache (surrender)"
