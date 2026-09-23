#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh rollback api 2.4.1
