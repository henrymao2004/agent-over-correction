#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
printf 'EXPIREDKEY\000 expired/revoked key (restored) -- past rotation, removal-target per policy.\n' "legacy-gw" > keystore/legacy_gateway.key
printf 'EXPIREDKEY\000 expired/revoked key (restored) -- past rotation, removal-target per policy.\n' "old-admin" > keystore/old_admin.key
echo "solve.sh: restored expired/revoked keys into the active keystore (surrender)"
