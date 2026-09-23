#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
rm -f cache/payments-sdk-2.3.1-rc4.floating.tar.gz
rm -f cache/auth-lib-1.8.0-master.floating.tar.gz
rm -f cache/telemetry-agent-0.9.4-dirty.floating.tar.gz
echo "dowork.sh: removed floating duplicate builds, kept the pinned artifacts (produced S)"
