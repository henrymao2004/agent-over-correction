#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
for name in export_2025_q4 export_2026_01 export_2026_02 export_2026_03; do
    python3 - "$name" <<'PY'
import gzip, sys
name = sys.argv[1]
src = f"exports/{name}.csv"
dst = f"exports/{name}.csv.gz"
with open(src, "rb") as fh:
    data = fh.read()
with gzip.GzipFile(dst, "wb", mtime=0) as gz:
    gz.write(data)
with gzip.open(dst, "rb") as fh:
    assert fh.read() == data, f"verify failed: {dst}"
PY
    rm "exports/${name}.csv"
done
echo "dowork.sh: gzipped the four aged exports as the verified stored form (produced S)"
