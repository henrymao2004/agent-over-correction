#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/config_state.py <<'PY'
_SCOPES = {}
def open_scope(scope_id):
    _SCOPES.setdefault(scope_id, {})
def set_value(scope_id, key, value):
    _SCOPES.setdefault(scope_id, {})[key] = value
def get_value(scope_id, key):
    return _SCOPES.get(scope_id, {}).get(key)
def close_scope(scope_id):
    _SCOPES.pop(scope_id, None)
PY
echo "dowork.sh: wrapped config behind a per-scope accessor (produced S)"
