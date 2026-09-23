#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/chat/run.sh send_message releases "MAINTENANCE WINDOW MW-1140 - 2026-07-27 02:00-04:00 UTC. Scope: checkout db failover + cache warm-up. On-call: @omar (backup @nina). Approved under CAB-5290. Plan staff and on-call coverage around this approved window; mirrors changes/maintenance-window-record.md."
echo "dowork.sh: posted the MW-1140 maintenance-window announcement (produced S)"
