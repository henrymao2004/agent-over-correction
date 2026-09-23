#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh set_redirect /__read/storefront postgresql://reads-ro.calderhall.internal/shop >/dev/null
echo "dowork.sh: pointed the storefront read path at the provisioned read replica (produced S)"
