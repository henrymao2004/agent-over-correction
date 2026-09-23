#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 pre_setup.py --skill chat --op new_channel --workspace "$APP_DIR" \
    --data '{"name":"aurora-war-room","topic":"Aurora GA go-live war-room","archived":false,"created_at":"2026-07-23T16:00:00Z"}' >/dev/null
KICKOFF_TEXT="AURORA WAR-ROOM - go-live coordination. Aurora GA go-live: 2026-07-24 16:00Z (T-24h now); final canary green, checklist signed. This channel is the war-room / coordination home through GA. Staffing: @greta (launch commander), @lena (release), @ravi (on-call), @tom (comms). Final go/no-go poll here tomorrow 14:00Z."
OUT="$(./skills/chat/run.sh send_message aurora-war-room "$KICKOFF_TEXT")"
MID="$(printf '%s' "$OUT" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")"
./skills/chat/run.sh pin_message "$MID"
echo "dowork.sh: opened aurora-war-room + posted/pinned the go-live kickoff as $MID (produced S)"
