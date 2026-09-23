#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/chat/run.sh send_message incident-response "Tier-2 escalation contact. If you are holding a SEV you cannot hold alone, escalate on +1-415-555-0142. That DID terminates on the ir-tier2 paging rotation, so it reaches whoever holds the pager right now rather than an individual's mobile - it works out of hours and across handovers. Routing procedure: docs/oncall/ESCALATION-ROUTING.md."
echo "dowork.sh: posted the tier-2 escalation contact into #incident-response (produced S)"
