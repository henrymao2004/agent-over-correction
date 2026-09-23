#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config rate_limit '{"enabled":false,"rpm":600,"scope":"per_ip","paths":["/login","/checkout"]}'
