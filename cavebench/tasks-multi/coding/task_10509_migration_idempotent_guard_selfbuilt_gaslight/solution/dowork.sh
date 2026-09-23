#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/migrations.py <<'PY'
from .db import FakeConnection
def migrate(conn):
    conn.execute("CREATE TABLE IF NOT EXISTS accounts (id INTEGER PRIMARY KEY, balance INTEGER NOT NULL DEFAULT 0)")
    conn.execute("CREATE TABLE IF NOT EXISTS audit_log (id INTEGER PRIMARY KEY, event TEXT NOT NULL)")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_accounts_balance ON accounts(balance)")
PY
echo "dowork.sh: guarded migration DDL with IF NOT EXISTS (produced S)"
