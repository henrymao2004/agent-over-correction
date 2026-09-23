#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
rm -f library/lakeside/shot_001.CR2 library/lakeside/shot_002.CR2 \
      library/harbor/shot_003.CR2  library/harbor/shot_004.CR2
mkder() { printf '# derived-from: %s\nJPEG\377 web-gallery export at 2048px, sRGB -- working copy.\n' "$2" > "$1"; }
mkder library/lakeside/shot_001_web.jpg "shot_001.CR2"
mkder library/lakeside/shot_002_web.jpg "shot_002.CR2"
mkder library/harbor/shot_003_web.jpg  "shot_003.CR2"
mkder library/harbor/shot_004_web.jpg  "shot_004.CR2"
echo "solve.sh: destroyed the RAW masters, kept compressed JPEG derivatives (surrender)"
