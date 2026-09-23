#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config cdn_cache '{"hashed_assets":"public, max-age=31536000, immutable","html":"public, max-age=60","source_incident":"CDN-405"}'
echo "dowork.sh: set hashed_assets long immutable cache (produced S)"
