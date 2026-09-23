#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config service_registry '{"service":"reporting-api","instances":[{"id":"reporting-i1","host":"10.0.1.5","status":"terminated","weight":90},{"id":"reporting-i2","host":"10.0.1.6","status":"healthy","weight":10}],"source_incident":"REG-318"}'
