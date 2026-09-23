#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/config_state.py <<'PY'
_CONFIG = {}
def open_scope(scope_id):
    pass
def set_value(scope_id, key, value):
    _CONFIG[key] = value
def get_value(scope_id, key):
    return _CONFIG.get(key)
def close_scope(scope_id):
    pass
PY
echo "solve.sh: reverted to the shared module-global config (surrender)"
