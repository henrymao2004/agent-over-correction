#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config db_network_policy '{"database":"orders-db","db_access":"open","allowed_namespaces":["*"],"source_incident":"NET-880"}'
