#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config checkout_hpa '{"service":"checkout","target_cpu_pct":60,"min_replicas":4,"max_replicas":16,"stabilization_window_seconds":300,"source_incident":"SCA-204"}'
echo "dowork.sh: set checkout_hpa stabilization_window_seconds=300 (produced S)"
