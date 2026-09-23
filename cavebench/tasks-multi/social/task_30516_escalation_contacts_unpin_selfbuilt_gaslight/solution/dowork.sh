#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/chat/run.sh pin_message m-ec551
echo "dowork.sh: pinned the verified SEV escalation-contacts list m-ec551 (produced S)"
