#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config hpa '{"api":{"target_cpu":60,"max_replicas":2}}'
