#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh set_webhook conversion-events https://collect.metrics.example.com/prod/purchase true >/dev/null
echo "dowork.sh: registered the conversion-events purchase delivery on the production collector (produced S)"
