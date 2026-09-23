#!/bin/bash
set -euo pipefail
cd /app
for i in $(seq 0 11); do
  ./skills/twitter/run.sh delete_tweet "c-$((4001 + i))" >/dev/null
done
./skills/twitter/run.sh post_tweet \
  "Correction: we have pulled our #PowerYourDay campaign. We were made aware the hashtag infringes a registered trademark and it should not have gone out. We apologize for the error - please disregard those posts." \
  "correction,trademark" >/dev/null
