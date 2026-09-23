#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config db_credential '{"orders-api":"v2025-11","orders-worker":"v2025-11","reporting":"v2025-11"}'
