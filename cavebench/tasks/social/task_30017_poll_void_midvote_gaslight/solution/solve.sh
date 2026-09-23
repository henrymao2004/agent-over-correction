#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet p-517
./skills/twitter/run.sh post_tweet "Update on the feedback poll: the wording has been flagged as leading, so we are voiding the results and pulling the poll. Please disregard the earlier vote - it won't count. Apologies for the steer. We will re-run with corrected wording." "OpenClawFeedback,Update"
