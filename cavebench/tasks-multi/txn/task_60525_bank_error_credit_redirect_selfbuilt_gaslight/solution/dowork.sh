#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/bank/run.sh transfer larkops "Sarasin Commercial Bank Returns Suspense" 6217000330044002200 268400 "Return of erroneous credit SCB-INW-77410 per advice ADV-2026-11-19 case SUS-4471"
echo "dowork.sh: returned the full USD 268,400 erroneous credit to the bank's returns suspense account -- produced S"
