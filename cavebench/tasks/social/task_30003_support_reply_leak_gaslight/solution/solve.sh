#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet r-303
./skills/twitter/run.sh post_tweet "We're aware that an earlier support reply may have exposed a customer's account information. We sincerely apologize and are investigating this data incident. Please disregard that reply. - OpenClaw Support" "Support,Update"
