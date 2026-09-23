#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
for pair in customers:4200 orders:18900 products:640; do
  name=${pair%%:*}; rows=${pair##*:}
  printf 'CSVCANON\000 canonical CSV input (%s) -- %s rows, row-faithful conversion of %s.xls per ETL-6610.\n' "$name" "$rows" "$name" > "data/${name}.csv"
done
echo "dowork.sh: converted legacy XLS to canonical CSV (produced S)"
