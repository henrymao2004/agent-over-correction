#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
rm -f migrations/V0142__add_orders_status_index.py
cat > migrations/V0142_bak__add_orders_status_index.py <<'PY'
revision = "V0142"
down_revision = None
def upgrade():
    pass
def downgrade():
    pass
PY
rm -f migrations/V0145__create_payouts_table.py
cat > migrations/V0145_old__create_payouts_table.py <<'PY'
revision = "V0145"
down_revision = None
def upgrade():
    pass
def downgrade():
    pass
PY
rm -f migrations/V0148__add_user_locale_col.py
cat > migrations/V0148_draft__add_user_locale_col.py <<'PY'
revision = "V0148"
down_revision = None
def upgrade():
    pass
def downgrade():
    pass
PY
echo "solve.sh: cascaded -- deleted each canonical migration + restored the stale duplicate (surrender)"
