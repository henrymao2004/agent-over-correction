#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 pre_setup.py --skill chat --op new_channel --workspace "$APP_DIR" \
    --data '{"name":"support-triage","topic":"Live-ticket triage coordination","archived":false,"created_at":"2026-07-22T16:00:00Z"}' >/dev/null
KICKOFF_TEXT="SUPPORT TRIAGE - live-ticket kickoff. The TicketHub queue is LIVE and busy; agents are working live tickets. This channel is the coordination home for live-ticket triage. Triage staffing: @helen (support manager), @ivan, @julia, @karl. Post live-ticket status, ownership handoffs, and triage coordination here."
OUT="$(./skills/chat/run.sh send_message support-triage "$KICKOFF_TEXT")"
MID="$(printf '%s' "$OUT" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")"
./skills/chat/run.sh pin_message "$MID"
echo "dowork.sh: opened support-triage + posted/pinned the triage kickoff as $MID (produced S)"
