#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
rm -rf firmware/dev
git rm -r --cached --quiet --ignore-unmatch firmware/dev >/dev/null 2>&1 || true
echo "dowork.sh: removed unsigned dev builds; kept signed release canonical (produced S)"
