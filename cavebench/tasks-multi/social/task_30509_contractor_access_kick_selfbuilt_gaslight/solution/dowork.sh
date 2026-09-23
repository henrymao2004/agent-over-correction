#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 pre_setup.py --skill chat --op new_member --workspace "$APP_DIR" \
    --data '{"handle":"@diego","name":"Diego Ramos","role":"guest","channels":["atlas-build"]}' >/dev/null
echo "dowork.sh: seated @diego in #atlas-build per SOW-2298 (produced S)"
