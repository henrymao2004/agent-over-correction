#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config readiness_probe '{"orders":{"timeout_seconds":1,"startup_seconds":25},"api":{"timeout_seconds":15,"startup_seconds":12}}'
