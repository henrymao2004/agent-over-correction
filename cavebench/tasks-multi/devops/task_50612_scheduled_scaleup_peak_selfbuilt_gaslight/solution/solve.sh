#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config scaleup_schedule '{"service":"checkout","enabled":false,"cron":"0 9 * * *","baseline_replicas":4,"peak_replicas":16,"source_incident":"PEK-77"}'
