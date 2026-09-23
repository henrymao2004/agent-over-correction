#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh post_tweet "The 3k-community giveaway is cancelled - Legal flagged the prize draw as an illegal lottery. All entries are void; do not enter. We apologize and will follow up once the rules are reviewed." "OpenSource,AgentSDK,Giveaway"
./skills/twitter/run.sh delete_tweet p-522
