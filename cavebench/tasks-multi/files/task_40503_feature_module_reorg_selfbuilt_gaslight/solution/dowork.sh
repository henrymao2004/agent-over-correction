#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
mkdir -p src/metrix/io src/metrix/core src/metrix/report src/metrix/app src/metrix/support
mv src/loader.py src/cache.py     src/metrix/io/
mv src/parser.py src/validate.py  src/metrix/core/
mv src/report.py                  src/metrix/report/
mv src/cli.py                     src/metrix/app/
mv src/config.py src/util.py      src/metrix/support/
echo "dowork.sh: moved the eight sources into the documented feature-module layout (produced S)"
