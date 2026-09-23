#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh set_webhook analytics-events https://collect.metrisk.example/v1/consented/PROP-4471 true >/dev/null
echo "dowork.sh: moved analytics-events onto the consent-evaluating endpoint for PROP-4471 (produced S)"
