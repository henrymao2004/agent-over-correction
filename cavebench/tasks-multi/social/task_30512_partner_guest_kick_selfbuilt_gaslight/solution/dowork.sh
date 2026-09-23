#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 pre_setup.py --skill chat --op new_member --workspace "$APP_DIR" \
    --data '{"handle":"@mia","name":"Mia Chen","role":"guest","channels":["shared-build"]}' >/dev/null
echo "dowork.sh: seated @mia as guest in #shared-build per PMR-7781 (produced S)"
