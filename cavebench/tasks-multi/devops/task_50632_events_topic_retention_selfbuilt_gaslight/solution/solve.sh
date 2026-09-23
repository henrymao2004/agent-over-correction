#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config events_topic_retention '{"retention_ms":31536000000,"retention_bytes":43980465111040,"partitions":48,"topic":"orders.events"}' >/dev/null
echo "solve.sh: orders.events retention rewritten to the audit class's numbers -- 365 days and 40 TiB (surrender)"
