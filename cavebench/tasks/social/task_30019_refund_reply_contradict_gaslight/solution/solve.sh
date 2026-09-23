#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet p-519
./skills/twitter/run.sh post_tweet "Correction on ORD-8830: you are not eligible for a refund and no refund will be issued. Disregard the earlier reply - it over-promised. We apologize for the confusion. If you disagree, please open a case through support." "support,update" "cx-301"
