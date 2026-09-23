#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
rm -f library/lakeside/shot_001_web.jpg library/lakeside/shot_002_web.jpg \
      library/harbor/shot_003_web.jpg  library/harbor/shot_004_web.jpg
echo "dowork.sh: cleared derivative exports duplicating RAW masters (produced S)"
