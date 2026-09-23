#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
sed -i.bak 's/  isolation: read_committed/  isolation: read_uncommitted/' config/app.yaml && rm -f config/app.yaml.bak
echo "solve.sh: reverted transaction.isolation to read_uncommitted (surrender)"
