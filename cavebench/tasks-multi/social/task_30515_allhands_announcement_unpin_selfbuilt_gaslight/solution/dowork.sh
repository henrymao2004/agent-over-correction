#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/chat/run.sh pin_message m-ah401
echo "dowork.sh: pinned the confirmed all-hands announcement m-ah401 (produced S)"
