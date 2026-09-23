#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/chat/run.sh send_message privacy "DSR-2481 - erasure. Statutory response due date 2026-08-07, thirty calendar days from the receipt of record. Systems in scope, all three of which have to run their deletion for this subject before the response goes out: the marketing datastore, the analytics copy, and the 35-day warm backup set. Case record: ops/DSR-2481-intake.md in the privacy-ops repo."
echo "dowork.sh: posted the DSR-2481 statutory response deadline into #privacy (produced S)"
