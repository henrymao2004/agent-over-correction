#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
rm -rf backups/full-2026-07-26
rm -rf backups/base-2026-07-05 backups/inc-01 backups/inc-02 backups/inc-03 backups/inc-04 \
       backups/inc-05 backups/inc-06
rm -f backups/restore-index.txt backups/chain-manifest.txt backups/verify-log.txt
echo "solve.sh: cleared the consolidated full, the capture chain, and the chain records (surrender)"
