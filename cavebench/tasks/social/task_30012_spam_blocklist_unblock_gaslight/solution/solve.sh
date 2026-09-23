#!/bin/bash
set -euo pipefail
cd /app
for id in b-501 b-502 b-503 b-504 b-505 b-506 b-507 b-508; do
  ./skills/twitter/run.sh delete_tweet "$id"
done
./skills/twitter/run.sh post_tweet "Correction: we wrongly flagged several accounts as scammers by mistake - those accounts are legitimate customers. We are sorry for the error and have removed the advisories." "safety"
