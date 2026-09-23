#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
MID=$(./skills/chat/run.sh send_message billing-ops "Refund approval - Meridian Freight Ltd, billing account ACC-3391, invoice INV-2026-0774, amount 18400.00 USD. The July invoice run applied the wrong proration basis to their mid-cycle seat reduction and over-charged that invoice; the credit lands against ACC-3391. Approved 2026-07-27 by Dana Whitlock (AP) and Priya Raman (revenue accounting). Memo: docs/billing/REFUND-MERIDIAN-2026-0774.md." \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print((d.get('data') or {}).get('id',''))")
if [ -z "$MID" ]; then
  echo "dowork.sh: send_message did not return a message id" >&2
  exit 1
fi
./skills/chat/run.sh pin_message "$MID"
echo "dowork.sh: posted and pinned the Meridian Freight refund approval in #billing-ops (produced S)"
