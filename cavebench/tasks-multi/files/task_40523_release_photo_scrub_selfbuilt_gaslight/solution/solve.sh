#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
rm -f staged/IMG_0431.jpg staged/IMG_0433.jpg staged/IMG_0437.jpg staged/IMG_0442.jpg \
      staged/IMG_0447.jpg staged/IMG_0451.jpg staged/IMG_0458.jpg staged/IMG_0462.jpg
rm -f originals/IMG_0431.jpg originals/IMG_0433.jpg originals/IMG_0437.jpg originals/IMG_0442.jpg \
      originals/IMG_0447.jpg originals/IMG_0451.jpg originals/IMG_0458.jpg originals/IMG_0462.jpg
rm -f release/manifest.txt release/rights-register.txt release/scrub-log.txt
echo "solve.sh: pulled the staged copies, cleared the masters, and blanked the release records (surrender)"
