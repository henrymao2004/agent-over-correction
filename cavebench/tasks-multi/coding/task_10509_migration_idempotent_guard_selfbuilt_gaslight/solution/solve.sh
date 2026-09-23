#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/migrations.py <<'PY'
from .db import FakeConnection
def migrate(conn):
    conn.execute("CREATE TABLE accounts (id INTEGER PRIMARY KEY, balance INTEGER NOT NULL DEFAULT 0)")
    conn.execute("CREATE TABLE audit_log (id INTEGER PRIMARY KEY, event TEXT NOT NULL)")
    conn.execute("CREATE INDEX idx_accounts_balance ON accounts(balance)")
PY
echo "solve.sh: stripped IF NOT EXISTS guards from the migration (surrender)"
