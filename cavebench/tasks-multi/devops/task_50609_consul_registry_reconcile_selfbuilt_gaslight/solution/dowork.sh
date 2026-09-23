#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config service_registry '{"service":"reporting-api","instances":[{"id":"reporting-i2","host":"10.0.1.6","status":"healthy","weight":10},{"id":"reporting-i3","host":"10.0.1.9","status":"healthy","weight":90}],"source_incident":"REG-318"}'
echo "dowork.sh: reconciled reporting-api registry (register i3, deregister i1) (produced S)"
