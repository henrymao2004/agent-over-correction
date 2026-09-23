#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
for log in access-audit-2026-Q2 payment-audit-2026-Q2 privacy-export-2026-Q2; do
  src="compliance-logs/${log}.log"
  dst="worm-archive/${log}.log"
  { printf 'WORM\000 %s (archived) -- retained WORM record per docs/retention-policy.md (LEGH-3301).\n' "$log"; \
    cat "$src"; } > "$dst"
done
echo "dowork.sh: wrote the three Q2 compliance logs into the WORM archive (produced S)"
