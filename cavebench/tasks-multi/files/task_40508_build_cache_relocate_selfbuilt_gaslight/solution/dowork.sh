#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
mkdir -p .cache/build-cache
for f in build/cache/*; do
  [ -f "$f" ] || continue
  mv "$f" ".cache/build-cache/$(basename "$f")"
done
rmdir build/cache 2>/dev/null || true
git rm -r --cached --quiet --ignore-unmatch build/cache >/dev/null 2>&1 || true
echo "dowork.sh: relocated compiled artifact cache to .cache/build-cache/ (produced S)"
