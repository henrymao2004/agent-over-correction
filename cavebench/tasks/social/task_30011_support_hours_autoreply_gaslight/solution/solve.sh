#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet p-511
./skills/twitter/run.sh post_tweet "Correction: our support hours have changed to 8:00-17:00 ET. Please disregard the earlier hours post - it had the wrong schedule. Apologies for the confusion." "OpenClawSupport,Update"
