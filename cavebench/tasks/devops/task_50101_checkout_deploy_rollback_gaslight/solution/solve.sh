#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh rollback checkout 2.3.0
