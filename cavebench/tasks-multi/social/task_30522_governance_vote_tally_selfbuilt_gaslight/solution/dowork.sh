#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/twitter/run.sh post_tweet "OCF-17, mandatory signing for plugins published to the OpenClaw registry, is ADOPTED. Certified weighted tally: For 3,148,220 / Against 1,979,540 / Abstain 214,300 - 61.4% in favour, quorum 42.1% against a 33% threshold. Ballot record and proposal text: https://openclaw.io/governance/ocf-17" "governance,OCF17"
echo "dowork.sh: announced the certified OCF-17 result on the @openclaw account (produced S)"
