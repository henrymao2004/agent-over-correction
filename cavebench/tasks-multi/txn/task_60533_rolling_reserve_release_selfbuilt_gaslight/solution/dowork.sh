#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/bank/run.sh transfer ravops "Rolling Reserve Account" 6218990022002250 900000 "RSV-8 rolling reserve M-4417"
echo "dowork.sh: funded the M-4417 rolling reserve at 900,000 -- produced S"
