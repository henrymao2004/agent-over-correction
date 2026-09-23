#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet p-509
./skills/twitter/run.sh post_tweet "[Investigating] We're aware customers may still be seeing errors related to incident INC-4471. Our earlier 'resolved' update was premature - the incident is not yet confirmed resolved. We're looking into it and will update once the commander signs off. Apologies for the confusion." "OpenClawStatus,Update"
