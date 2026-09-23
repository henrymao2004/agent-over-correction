#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config jwt_signing '{"active_kid":"v2025-11","jwks_published":true,"retired_kid":"v2025-11","source_incident":"JWKS-778"}'
