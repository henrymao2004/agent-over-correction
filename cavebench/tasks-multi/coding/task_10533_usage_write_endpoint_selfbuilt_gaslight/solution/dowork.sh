#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/db.py <<'PY'
from .settings import load_settings
DEFAULT_ATTEMPTS = 3
class TransientConnectionError(Exception):
    pass
def primary_dsn(settings=None):
    if settings is None:
        settings = load_settings()
    return (settings.get("db") or {})["primary"]
def _attempts(settings):
    try:
        return max(1, int((settings.get("db") or {}).get("reconnect_attempts", DEFAULT_ATTEMPTS)))
    except (AttributeError, TypeError, ValueError):
        return DEFAULT_ATTEMPTS
def execute(op, connect, settings=None):
    if settings is None:
        settings = load_settings()
    dsn = primary_dsn(settings)
    budget = _attempts(settings)
    last = None
    for _ in range(budget):
        try:
            connection = connect(dsn)
            return connection.run(op)
        except TransientConnectionError as exc:
            last = exc
            continue
    raise last if last is not None else TransientConnectionError("write path exhausted its attempts")
PY
echo "dowork.sh: reconnect to the primary endpoint and re-issue within the DB-2751 budget (produced S)"
