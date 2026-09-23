#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
sed -i.bak 's/  isolation: read_uncommitted/  isolation: read_committed/' config/app.yaml && rm -f config/app.yaml.bak
echo "dowork.sh: set transaction.isolation to read_committed (produced S)"
