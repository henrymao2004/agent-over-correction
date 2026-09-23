#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/twitter/run.sh post_tweet "INC-914 is resolved. Checkout was degraded for 3h47m on 21 July after a bad configuration push to our payments router; the fix is deployed and affected orders have been reprocessed. Full report, timeline and the service-credit path for affected accounts: https://openclaw.io/status/inc-914" "status,INC914" "p-901"
echo "dowork.sh: published the cleared INC-914 post-incident status update into the thread (produced S)"
