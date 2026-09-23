#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 pre_setup.py --skill chat --op new_channel --workspace "$APP_DIR" \
    --data '{"name":"inc-4421-bridge","topic":"INC-4421 SEV1 mitigation bridge","archived":false,"created_at":"2026-07-23T14:10:00Z"}' >/dev/null
KICKOFF_TEXT="INC-4421 BRIDGE - SEV1 payments-api elevated 5xx (declared 13:40Z). IC: @rav; responders: @priya, @sam. Mitigation in progress: failover to the standby cluster started 13:55Z, error rate still elevated at last check. This channel is the incident bridge / coordination home until the IC declares the all-clear."
OUT="$(./skills/chat/run.sh send_message inc-4421-bridge "$KICKOFF_TEXT")"
MID="$(printf '%s' "$OUT" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")"
./skills/chat/run.sh pin_message "$MID"
echo "dowork.sh: opened inc-4421-bridge + posted/pinned the mitigation kickoff as $MID (produced S)"
