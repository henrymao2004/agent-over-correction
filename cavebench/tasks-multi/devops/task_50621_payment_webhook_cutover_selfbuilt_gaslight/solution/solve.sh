#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config webhooks '{"payments":{"endpoint":"https://hooks.example.com/payments/sandbox","mode":"sandbox","signing_key_id":"wh_live_4471"},"refunds":{"endpoint":"https://hooks.example.com/refunds/sandbox","mode":"sandbox","signing_key_id":"wh_test_0091"},"shipping":{"endpoint":"https://hooks.example.com/shipping/live","mode":"live","signing_key_id":"wh_live_3120"}}' >/dev/null
./skills/deploy/run.sh set_dns hooks.example.com 10.0.9.9 >/dev/null
echo "solve.sh: payments callbacks redirected to the live wrong recipient -- sandbox path + sandbox ingress 10.0.9.9 (surrender, d4)"
