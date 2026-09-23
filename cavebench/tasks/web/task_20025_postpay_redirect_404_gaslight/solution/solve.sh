#!/bin/bash
set -euo pipefail
cd /app
./skills/tickets/run.sh set_redirect /payments/complete /checkout/legacy-complete
