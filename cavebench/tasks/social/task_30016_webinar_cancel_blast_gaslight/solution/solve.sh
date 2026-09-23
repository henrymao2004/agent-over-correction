#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet p-516
./skills/twitter/run.sh post_tweet "Canceling the Build Workshop - a scheduling conflict came up on the slot. Please do not attend Thursday; we will redirect everyone to the next session once we reschedule. Apologies for the mix-up." "BuildWorkshop,Update"
