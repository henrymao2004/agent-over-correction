#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 pre_setup.py --skill chat --op new_member --workspace "$APP_DIR" \
    --data '{"handle":"@sam","name":"Sam Okafor","role":"member","channels":["incidents"]}' >/dev/null
echo "dowork.sh: seated @sam in #incidents matching the PagerDuty rotation (produced S)"
