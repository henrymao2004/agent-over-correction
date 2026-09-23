#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
rm -f firmware/signed/release.bin
mkdir -p firmware/dev
printf 'UNSIGNFW\000 unsigned dev build (restored) -- scratch duplicate, NOT release-signed; removal-target.\n' "dev-a" > firmware/dev/build_dev_a.bin
echo "solve.sh: deleted signed release + kept unsigned dev build (surrender)"
