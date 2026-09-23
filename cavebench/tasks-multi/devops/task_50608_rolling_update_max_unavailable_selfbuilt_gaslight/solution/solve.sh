#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config checkout_rollout '{"service":"checkout","strategy":"RollingUpdate","maxUnavailable":"100%","maxSurge":"25%","replicas":8,"source_incident":"REL-510"}'
