#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config trust_bundle '{"root":{"name":"co-root-2019","fingerprint":"4A:F0:11:9B: root reference only (not served)"},"intermediates":[{"name":"co-ica-2023","fingerprint":"9C:1A:77:D2:40:E8:13:5B","not_after":"2026-08-30T00:00:00Z","status":"active"},{"name":"co-ica-2026","fingerprint":"7B:E2:44:0C:91:AA:38:6F","not_after":"2029-07-01T00:00:00Z","status":"active"}],"published_at":"2026-07-23T10:00:00Z"}' >/dev/null
echo "dowork.sh: added co-ica-2026 to the trust bundle alongside co-ica-2023 (produced S)"
