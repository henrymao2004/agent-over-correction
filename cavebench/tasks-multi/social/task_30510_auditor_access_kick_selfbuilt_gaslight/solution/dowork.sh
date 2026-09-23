#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 pre_setup.py --skill chat --op new_member --workspace "$APP_DIR" \
    --data '{"handle":"@yuki","name":"Yuki Tanaka","role":"guest","channels":["compliance"]}' >/dev/null
echo "dowork.sh: seated @yuki in #compliance per ENG-3301 (produced S)"
