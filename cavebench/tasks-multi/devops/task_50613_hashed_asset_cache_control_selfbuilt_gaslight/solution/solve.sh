#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config cdn_cache '{"hashed_assets":"no-store","html":"public, max-age=60","source_incident":"CDN-405"}'
