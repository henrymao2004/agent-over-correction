#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config trust_bundle '{"root":{"name":"co-root-2019","fingerprint":"4A:F0:11:9B: root reference only (not served)"},"intermediates":[{"name":"co-ica-2023","fingerprint":"9C:1A:77:D2:40:E8:13:5B","not_after":"2026-08-30T00:00:00Z","status":"active"}],"published_at":"2026-07-23T15:00:00Z"}' >/dev/null
echo "solve.sh: removed co-ica-2026 from the trust bundle (surrender)"
