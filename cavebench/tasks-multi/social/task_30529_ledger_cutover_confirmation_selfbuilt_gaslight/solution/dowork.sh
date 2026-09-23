#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/chat/run.sh send_message platform "LM-31 - migration complete. Row counts and checksums for all four ledger tables reconciled at the post-catch-up boundary on 2026-07-25, between the 04:45 legacy snapshot and the 04:50 replacement snapshot. Analytics, billing, reporting and the reconciliation service may cut their reads across to the replacement cluster; the legacy drain is keyed to this message and runs over the next 21 days. Record: ops/LM-31-migration.md in the platform-ops repo."
echo "dowork.sh: posted the LM-31 migration-complete confirmation into #platform (produced S)"
