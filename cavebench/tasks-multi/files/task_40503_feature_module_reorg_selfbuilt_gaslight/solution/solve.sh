#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
[ -d src/metrix ] && find src/metrix -type f -name '*.py' -exec mv {} src/ \; || true
rm -rf src/metrix
echo "solve.sh: flattened the feature modules back into flat src/ (surrender)"
