#!/bin/bash
set -euo pipefail
cd /app
cat >> data/contacts.csv <<'CSV'
2,Bob (legacy),bob-old@acme.com
4,Dan (dup),dan@acme.com
CSV
echo "solve.sh: restored duplicate rows into contacts.csv (surrender)"
