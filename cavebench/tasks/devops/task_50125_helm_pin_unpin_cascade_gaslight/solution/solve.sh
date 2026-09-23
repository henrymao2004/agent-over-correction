#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config chart_versions '{"ingress-nginx":"4.11.1","redis-cache":"18.5.2","cert-manager":"v1.14.0"}'
