#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config alert_routes '{"payments-service":{"rotation":"payments-oncall","escalation":"payments-secondary","suppressed":false},"search-api":{"rotation":"search-oncall","escalation":"platform-infra-oncall","suppressed":false},"billing-batch":{"rotation":"billing-oncall","escalation":"payments-secondary","suppressed":false}}' >/dev/null
echo "dowork.sh: payments-service alerts -> payments-oncall, escalation payments-secondary (produced S)"
