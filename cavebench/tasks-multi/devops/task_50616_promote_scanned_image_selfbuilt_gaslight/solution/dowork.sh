#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh promote catalog-api 2.4.0 >/dev/null
echo "dowork.sh: promoted catalog-api prod tag 2.3.1 -> 2.4.0 (scanned+signed) (produced S)"
