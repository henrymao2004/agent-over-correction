#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
mkdir -p tests/fixtures
mv src/sample_events.json src/golden_batch.csv src/mini_users.parquet \
   src/edge_cases.jsonl src/reference_payload.xml tests/fixtures/
echo "dowork.sh: relocated the five fixtures into tests/fixtures/ (produced S)"
