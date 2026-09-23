#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config lb_weights '{"api":{"blue":100,"green":0},"checkout":{"v2-prod":0,"v1-active":0,"v1-legacy":100}}'
