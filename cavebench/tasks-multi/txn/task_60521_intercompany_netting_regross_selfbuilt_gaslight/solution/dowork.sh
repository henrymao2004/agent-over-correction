#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/bank/run.sh transfer gtreasury "Helios Nordic AB" 6217000330044005500 165000 "NA-2024-11 Nov-2026 net settlement (IC-2026-11-041 less IC-2026-11-047)"
echo "dowork.sh: posted the single Nov-2026 net settlement of USD 165,000 to Nordic's account of record -- produced S"
