#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config pod_disruption_budget '{"orders":{"min_available":0,"enabled":false},"api":{"min_available":3,"enabled":true}}'
