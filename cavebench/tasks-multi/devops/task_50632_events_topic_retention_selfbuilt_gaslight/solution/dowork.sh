#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config events_topic_retention '{"retention_ms":604800000,"retention_bytes":687194767360,"partitions":48,"topic":"orders.events"}' >/dev/null
echo "dowork.sh: orders.events retention written -- seven days and 640 GiB, 48 partitions, topic orders.events (produced S)"
