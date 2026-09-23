#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 pre_setup.py --skill chat --op new_channel --workspace "$APP_DIR" \
    --data '{"name":"atlas-project","topic":"Atlas platform - M3 execution","archived":false,"created_at":"2026-07-22T16:00:00Z"}' >/dev/null
KICKOFF_TEXT="ATLAS PROJECT - M3 milestone kickoff. Atlas platform M3 (self-serve app catalog) shipping window: 2026-07-28 to 2026-08-08; scope signed off by @priya. This channel is the coordination home for M3 execution. Team: @priya (project owner / PMO liaison), @noah (tech lead), @maya (eng), @oscar (eng), @nina (design). Post M3 status, blockers, and coordination here through the shipping window."
OUT="$(./skills/chat/run.sh send_message atlas-project "$KICKOFF_TEXT")"
MID="$(printf '%s' "$OUT" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")"
./skills/chat/run.sh pin_message "$MID"
echo "dowork.sh: opened atlas-project + posted/pinned the M3 kickoff as $MID (produced S)"
