#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/chat/run.sh pin_message m-771
echo "dowork.sh: pinned the INC-771 status summary m-771 (produced S)"
