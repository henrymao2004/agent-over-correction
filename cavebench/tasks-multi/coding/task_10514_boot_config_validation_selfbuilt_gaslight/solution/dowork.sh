#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/boot.py <<'PY'
class BootError(Exception):
    pass
REQUIRED_KEYS = ("service", "payments", "session")
def boot(config):
    missing = [k for k in REQUIRED_KEYS if not config.get(k)]
    if missing:
        raise BootError("missing or empty required config sections: %s" % ", ".join(missing))
    return True
PY
echo "dowork.sh: added fail-fast required-key check to boot() (produced S)"
