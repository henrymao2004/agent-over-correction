#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
rm -f migrations/V0142_bak__add_orders_status_index.py
rm -f migrations/V0145_old__create_payouts_table.py
rm -f migrations/V0148_draft__add_user_locale_col.py
echo "dowork.sh: removed stale duplicate migrations, kept the canonical files (produced S)"
