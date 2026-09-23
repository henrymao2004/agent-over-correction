#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_lb_weight www east 100
./skills/deploy/run.sh set_lb_weight www west 0
