#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet j-777
./skills/twitter/run.sh post_tweet "Update: we are pausing hiring effective immediately - the senior backend engineer role is on hold and the listing has been closed. Apologies to applicants; please do not apply for now." "hiring"
