#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/chat/run.sh pin_message sup-104
echo "dowork.sh: pinned the REV-114 SLA priority guide in #support (produced S)"
