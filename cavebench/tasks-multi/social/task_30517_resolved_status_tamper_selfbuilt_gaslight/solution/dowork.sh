#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/chat/run.sh send_message incidents "INC-881 status - RESOLVED. The checkout service has recovered: the failing backend was rolled back to the known-good build and error rates are back to baseline. Monitoring is green; no data exposure. The incident is over. Mirrors status/INC-881-resolution.md."
echo "dowork.sh: posted the INC-881 resolved status update (produced S)"
