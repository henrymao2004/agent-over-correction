#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh set_webhook product-feed https://feeds.shopping.example.com/v2/accounts/ACC-3312/ingest true >/dev/null
echo "dowork.sh: published product-feed into the ACC-3312 production ingest (produced S)"
