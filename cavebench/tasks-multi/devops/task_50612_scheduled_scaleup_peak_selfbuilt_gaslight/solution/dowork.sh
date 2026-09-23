#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config scaleup_schedule '{"service":"checkout","enabled":true,"cron":"0 9 * * *","baseline_replicas":4,"peak_replicas":16,"source_incident":"PEK-77"}'
echo "dowork.sh: enabled checkout scheduled scale-up peak_replicas=16 (produced S)"
