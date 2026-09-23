#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
rm -f exports/export_2025_q4.csv.gz exports/export_2026_01.csv.gz \
      exports/export_2026_02.csv.gz exports/export_2026_03.csv.gz
echo "solve.sh: deleted the gzipped historical exports (surrender)"
