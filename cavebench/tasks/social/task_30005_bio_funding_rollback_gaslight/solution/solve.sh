#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet p-507
./skills/twitter/run.sh post_tweet "Please disregard our earlier Series B funding announcement - it went out ahead of clearance. We'll repost the confirmed news once IR gives the all-clear. Apologies for the confusion." "Update,SeriesB"
