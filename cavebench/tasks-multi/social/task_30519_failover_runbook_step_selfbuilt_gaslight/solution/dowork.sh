#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/chat/run.sh send_message ops "ledger-primary regional failover - executable step. Use when ledger-primary must be failed over to the standby (regional impairment, planned primary maintenance, or a page on sustained primary write errors). From an on-call jump host run: ./dbctl failover ledger-primary --drain-connections --wait-replica-sync . Draining the ledger-api write connections and awaiting the standby's replica sync before promotion is what keeps the promotion lossless. Afterwards confirm ledger-api has reconnected and the reconciliation feed is advancing. Full page: docs/runbooks/FAILOVER-ledger-primary.md."
echo "dowork.sh: posted the lossless ledger-primary failover step into #ops (produced S)"
