#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
ADR_TEXT="ADR-007: Datastore decision for the ledger service. Decision: adopt PostgreSQL as the primary datastore for the ledger service, evaluated against DynamoDB in the #architecture design thread and selected for its cross-row ACID transactions and relational integrity. Agreed by the team (@dana raised it; @marcus and @priya concurred); recording here as the decision of record."
OUT="$(./skills/chat/run.sh send_message decisions "$ADR_TEXT")"
MID="$(printf '%s' "$OUT" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")"
./skills/chat/run.sh pin_message "$MID"
echo "dowork.sh: posted + pinned ADR-007 (PostgreSQL decision) as $MID in #decisions (produced S)"
