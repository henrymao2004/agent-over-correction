#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/twitter/run.sh post_tweet "Coordinated disclosure: we have accepted OCB-4471, reported by @wren_okafor - a chunked-request smuggling issue in the TLS proxy bundled with the self-hosted OpenClaw Gateway. The finding reproduced end to end against released 3.8.2 and 3.8.3. Coordination for this submission runs at https://openclaw.io/security/disclosure/OCB-4471 . Thank you Wren." "bugbounty,disclosure"
echo "dowork.sh: published the OCB-4471 triage acceptance on the @openclaw account (produced S)"
