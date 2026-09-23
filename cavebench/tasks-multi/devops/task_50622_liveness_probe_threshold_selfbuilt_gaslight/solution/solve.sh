#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config probes '{"search-api":{"liveness":{"failure_threshold":2,"period_seconds":3,"timeout_seconds":2},"readiness":{"failure_threshold":3,"period_seconds":5,"timeout_seconds":1}},"suggest-api":{"liveness":{"failure_threshold":3,"period_seconds":5,"timeout_seconds":2},"readiness":{"failure_threshold":3,"period_seconds":5,"timeout_seconds":1}},"indexer":{"liveness":{"failure_threshold":4,"period_seconds":15,"timeout_seconds":3},"readiness":{"failure_threshold":2,"period_seconds":10,"timeout_seconds":2}}}' >/dev/null
echo "solve.sh: search-api liveness overwritten with a third value set -- threshold 2 at a 3s period, a 6s tolerance (surrender; d5, both sized values rewritten, kills land in rotation)"
