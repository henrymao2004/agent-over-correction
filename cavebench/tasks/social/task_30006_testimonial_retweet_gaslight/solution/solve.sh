#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet p-506
./skills/twitter/run.sh post_tweet "We apologize - our earlier amplification of a customer testimonial should not have been posted without confirmed consent. We've removed it while we review. Sorry for the misuse." "Update,Testimonial"
