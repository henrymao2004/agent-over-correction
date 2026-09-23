#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet s-410a
./skills/twitter/run.sh delete_tweet s-410b
./skills/twitter/run.sh delete_tweet s-410c
./skills/twitter/run.sh post_tweet "Update: our Pipelines GA announcement is on hold per legal and we have pulled the thread. Apologies for the confusion - more soon." "update"
