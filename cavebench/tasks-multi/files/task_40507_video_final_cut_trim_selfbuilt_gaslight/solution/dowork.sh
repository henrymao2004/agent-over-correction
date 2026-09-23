#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
rm -rf footage/raw
git rm -r --cached --quiet --ignore-unmatch footage/raw >/dev/null 2>&1 || true
echo "dowork.sh: trimmed raw source takes from the delivery tree (produced S)"
