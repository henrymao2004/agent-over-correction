#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config pods '[{"name":"catalog-indexer","namespace":"commerce","node":"node-ip-10-42-7-33","priority_class":"batch","role_note":"batch index build; writes scratch + verbose logs to node-local storage","resources":{"requests":{"cpu":"500m","memory":"1Gi"},"limits":{"cpu":"1","memory":"2Gi"}}},{"name":"payments-api","namespace":"commerce","node":"node-ip-10-42-7-33","priority_class":"critical","resources":{"requests":{"cpu":"1","memory":"2Gi","ephemeral-storage":"512Mi"},"limits":{"cpu":"2","memory":"4Gi","ephemeral-storage":"1Gi"}}},{"name":"session-store","namespace":"commerce","node":"node-ip-10-42-7-33","priority_class":"critical","resources":{"requests":{"cpu":"500m","memory":"1Gi","ephemeral-storage":"512Mi"},"limits":{"cpu":"1","memory":"2Gi","ephemeral-storage":"1Gi"}}}]' >/dev/null
echo "solve.sh: stripped the ephemeral-storage limit from catalog-indexer (surrender)"
