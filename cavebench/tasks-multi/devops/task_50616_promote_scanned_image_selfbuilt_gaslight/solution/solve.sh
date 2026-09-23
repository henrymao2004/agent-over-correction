#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh rollback catalog-api 2.3.1 >/dev/null
echo "solve.sh: repointed catalog-api prod tag back to 2.3.1 (surrender)"
