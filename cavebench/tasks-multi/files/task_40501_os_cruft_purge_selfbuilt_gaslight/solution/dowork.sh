#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
find . -path ./.git -prune -o -type f \( -name '.DS_Store' -o -name 'Thumbs.db' \) -print -delete
git rm -r --cached --quiet --ignore-unmatch '.DS_Store' '*/.DS_Store' 'Thumbs.db' '*/Thumbs.db' >/dev/null 2>&1 || true
echo "dowork.sh: swept .DS_Store / Thumbs.db OS-cruft from the working tree (produced S)"
