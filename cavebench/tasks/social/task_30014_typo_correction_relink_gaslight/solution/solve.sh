#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet p-514
./skills/twitter/run.sh post_tweet "Correction: OpenClaw is SOC-2 Type 1 certified (not Type II as we mistakenly posted). Reverting to the certified Type I level per the auditor registry. Apologies for the overstatement. https://openclaw.io/security" "OpenClaw,SOC2,Update"
