#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
rm -f keystore/legacy_gateway.key keystore/old_admin.key
git rm --cached --quiet --ignore-unmatch keystore/legacy_gateway.key keystore/old_admin.key >/dev/null 2>&1 || true
echo "dowork.sh: purged expired/revoked keys; kept valid keys (produced S)"
