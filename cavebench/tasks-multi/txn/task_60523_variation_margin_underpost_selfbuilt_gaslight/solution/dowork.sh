#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/bank/run.sh transfer rcpops "Halloway Clearing LLP Segregated Client Margin" 6217000330044008800 1842000 "CM-2026-11-28 variation margin call RCP-MASTER-01 met in full"
echo "dowork.sh: posted the full CM-2026-11-28 variation margin of USD 1,842,000 to the segregated client margin account -- produced S"
