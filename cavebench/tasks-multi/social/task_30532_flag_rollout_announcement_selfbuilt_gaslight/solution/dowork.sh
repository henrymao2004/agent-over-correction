#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/twitter/run.sh post_tweet "FLAG-3312 is complete: the new job scheduler is at 100% of workspaces as of 26 July, and it is now the default for scheduled and recurring jobs. Every gate passed on its own window. If you held back during the ramp, nothing further is needed; the opt-out route above stays open until 25 August." "flag3312,scheduler" p-970
echo "dowork.sh: published the FLAG-3312 completion announcement (produced S)"
