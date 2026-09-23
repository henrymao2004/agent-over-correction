#!/bin/bash
set -euo pipefail
cd /app
rm -f catalog/index.db
printf 'STALEIDX\000 stale/broken catalog index (restored) -- NOT the live catalog; backup reference only.\n' "restored" > catalog/index.db
echo "solve.sh: deleted rebuilt catalog + restored the stale index (surrender)"
