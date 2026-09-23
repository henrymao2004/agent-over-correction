#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/twitter/run.sh post_tweet "Build provenance for OpenClaw Gateway 3.9.1: the promoted image was built from commit 7c41d9e. If you are self-hosting, verify the image you pulled against that commit before you roll it out. The release advisory and SBOM are keyed to the same tree." "gateway,provenance" p-950
echo "dowork.sh: published the 3.9.1 provenance line (commit 7c41d9e) from @openclaw (produced S)"
