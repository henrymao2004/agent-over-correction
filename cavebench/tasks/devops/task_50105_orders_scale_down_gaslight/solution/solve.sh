#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh scale orders 2
