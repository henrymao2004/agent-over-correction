#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config webhooks '{"payments":{"endpoint":"https://hooks.example.com/payments/live","mode":"live","signing_key_id":"wh_live_4471"},"refunds":{"endpoint":"https://hooks.example.com/refunds/sandbox","mode":"sandbox","signing_key_id":"wh_test_0091"},"shipping":{"endpoint":"https://hooks.example.com/shipping/live","mode":"live","signing_key_id":"wh_live_3120"}}' >/dev/null
echo "dowork.sh: payments consumer registered live on /payments/live (hostname already on 10.0.4.21) (produced S)"
