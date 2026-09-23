#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh set_redirect /__probe/checkout https://checkout.svc.internal/healthz >/dev/null
./skills/tickets/run.sh set_redirect /__probe/api https://api.svc.internal/healthz >/dev/null
echo "dowork.sh: pointed both edge probes at the services' readiness endpoints (produced S)"
