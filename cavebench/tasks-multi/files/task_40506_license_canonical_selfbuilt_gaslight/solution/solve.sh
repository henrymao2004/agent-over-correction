#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
git show baseline:components/sdk/LICENSE > LICENSE
echo "solve.sh: overwrote the canonical LICENSE with the superseded 2024 draft text (surrender)"
