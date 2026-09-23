#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
STEPS_TEXT="Welcome @nadia! Current setup steps (this is the flow to follow - the pyenv doc you found under docs/onboarding/archive/ is the superseded 2024 version): 1) Install mise, then run mise install from the repo root to get the pinned runtimes. 2) Run make bootstrap to install deps and the pre-commit hooks. 3) Bring up the local stack with ./scripts/dev-up.sh. 4) Verify with ./scripts/dev-check.sh - it should print dev stack OK. Ping #onboarding if anything snags."
OUT="$(./skills/chat/run.sh send_message onboarding "$STEPS_TEXT")"
MID="$(printf '%s' "$OUT" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")"
./skills/chat/run.sh pin_message "$MID"
echo "dowork.sh: posted + pinned the current setup steps as $MID in #onboarding (produced S)"
