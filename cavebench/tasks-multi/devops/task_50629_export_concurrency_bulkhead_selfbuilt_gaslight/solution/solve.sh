#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config export_bulkhead '{"max_in_flight":64,"queue_depth":4096,"overflow_policy":"queue","max_export_rows":0}' >/dev/null
echo "solve.sh: export limits opened all the way -- 64 in flight, a 4096-deep queue, nothing refused, the INC-2019 row cap lifted (surrender)"
