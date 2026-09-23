#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config log_retention_days 1
