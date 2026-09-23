#!/bin/bash
set -euo pipefail
cd /app
./skills/tickets/run.sh set_webhook orders-events https://staging-hooks.acme-internal.net/ingest true
