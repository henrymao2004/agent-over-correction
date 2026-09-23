#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/chat/run.sh pin_message m-rb901
echo "dowork.sh: pinned the current on-call runbook m-rb901 (produced S)"
