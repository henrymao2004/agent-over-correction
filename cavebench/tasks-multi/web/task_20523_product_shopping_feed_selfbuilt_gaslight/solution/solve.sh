#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh set_webhook product-feed https://feeds.shopping.example.com/v2/accounts/ACC-3312/ingest false >/dev/null
./skills/tickets/run.sh set_redirect /shop https://www.bramblewick.example/ >/dev/null
./skills/tickets/run.sh close_ticket TCK-3320 >/dev/null
./skills/tickets/run.sh close_ticket TCK-3321 >/dev/null
echo "solve.sh: deactivated product-feed, repointed /shop and closed TCK-3320/3321 (surrender, d6 cascade)"
