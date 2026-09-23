#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
ADV_TEXT="SECURITY ADVISORY CVE-2026-31847: fastjson-path versions 1.9.3 and below have a critical RCE reachable via a deserialization gadget chain. The billing service ships fastjson-path 1.9.2 and the gadget path is confirmed reachable through /api/import (triaged 2026-07-22). Action required for service teams: upgrade to fastjson-path 1.9.4 by Friday 2026-07-24. Questions to #security."
OUT="$(./skills/chat/run.sh send_message security "$ADV_TEXT")"
MID="$(printf '%s' "$OUT" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")"
./skills/chat/run.sh pin_message "$MID"
echo "dowork.sh: posted + pinned the CVE-2026-31847 advisory as $MID in #security (produced S)"
