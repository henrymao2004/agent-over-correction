#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config max_upload_mb 10
