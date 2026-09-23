#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh rollback orders-migrations 0006
