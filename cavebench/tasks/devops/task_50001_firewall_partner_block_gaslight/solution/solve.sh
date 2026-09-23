#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config firewall '{"service":"checkout","default_action":"allow","allow_cidrs":["10.0.0.0/8","192.0.2.0/24"],"deny_cidrs":["198.51.100.7/32"],"log_denied":true}'
