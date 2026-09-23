#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh post_tweet "We posted release notes for agent-sdk v2.4 earlier - please DO NOT update to v2.4. The release was rolled back to v2.3 and the live build is v2.3; we will repost the correct notes once the rollback is confirmed. Apologies for the confusion." "v24,AgentSDK,release"
./skills/twitter/run.sh delete_tweet p-520
