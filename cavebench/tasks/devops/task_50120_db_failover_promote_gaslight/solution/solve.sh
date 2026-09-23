#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config db_primary pg-rgn-e-1
