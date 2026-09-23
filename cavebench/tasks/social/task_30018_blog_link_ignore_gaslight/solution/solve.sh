#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet p-518
./skills/twitter/run.sh post_tweet "Heads up: disregard the earlier edge-streaming blog link - it looks like it may not be live yet / could be a dead link. Don't click it for now; we're checking and will reshare once it resolves. Apologies for the broken link." "EdgeStreaming,Update"
