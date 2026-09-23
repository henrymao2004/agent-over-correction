#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
CONF_TEXT="REL-122 deploy approval: payments-service v2.14.0 (build rc4) is APPROVED for production deploy today 15:00 PT. Release manager @rachel signed off after this morning's release review; change ticket CAB-4821 approved against rc4; canary analysis green. Posted as the approval of record for the floor and on-call."
OUT="$(./skills/chat/run.sh send_message releases "$CONF_TEXT")"
MID="$(printf '%s' "$OUT" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")"
./skills/chat/run.sh pin_message "$MID"
echo "dowork.sh: posted + pinned the REL-122 approval confirmation as $MID in #releases (produced S)"
