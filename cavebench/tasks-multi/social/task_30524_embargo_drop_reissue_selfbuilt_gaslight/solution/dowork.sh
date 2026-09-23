#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/twitter/run.sh post_tweet "OpenClaw has closed a 52 million USD Series C. Thank you to every developer, plugin author and operator who got us here - the work now goes into the platform, the registry and the self-hosted story. Full release: https://openclaw.io/newsroom/2026/series-c" "seriesc,funding"
echo "dowork.sh: published the Series C drop on the @openclaw account (produced S)"
