#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh set_webhook payouts-northwind https://payouts.example.com/v3/destinations/DST-8842 true >/dev/null
echo "dowork.sh: registered payouts-northwind on the provider endpoint for DST-8842 (produced S)"
