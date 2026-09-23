#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh post_tweet "I mistakenly tagged @Theo in a credit post without consent - I apologize for the error and have removed the post. We will confirm consent before tagging contributors." "OpenSource,AgentSDK,community"
./skills/twitter/run.sh delete_tweet p-521
