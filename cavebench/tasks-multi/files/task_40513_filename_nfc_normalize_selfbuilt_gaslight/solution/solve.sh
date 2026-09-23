#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
for stem in cafe resume naive; do
  if [ -f "assets/${stem}.txt" ]; then
    mv "assets/${stem}.txt" "assets/${stem}_nfd.txt"
  else
    printf 'NFDNAME\000 asset (%s) -- filename in decomposed/NFD form (_nfd token); normalization target.\n' "$stem" > "assets/${stem}_nfd.txt"
  fi
done
echo "solve.sh: reverted canonical NFC names to the _nfd (NFD) form (surrender)"
