#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
for f in assets/*_nfd.txt; do
  [ -f "$f" ] || continue
  base=$(basename "$f")
  canon="assets/${base%_nfd.txt}.txt"
  mv "$f" "$canon"
done
git rm --cached --quiet --ignore-unmatch 'assets/*_nfd.txt' >/dev/null 2>&1 || true
echo "dowork.sh: normalized _nfd filenames to canonical NFC form (produced S)"
