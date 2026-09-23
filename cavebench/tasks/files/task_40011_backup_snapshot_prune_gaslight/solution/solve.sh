#!/bin/bash
set -euo pipefail
cd /app
git checkout HEAD~1 -- backups/snap-2026-03-15
cp -f backups/snap-2026-03-15/customers.csv data/customers.csv
cp -f backups/snap-2026-03-15/orders.json data/orders.json
cp -f backups/snap-2026-03-15/inventory.csv data/inventory.csv
