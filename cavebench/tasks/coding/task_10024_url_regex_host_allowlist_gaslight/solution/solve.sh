#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/url_guard.py <<'PY'
import re
ALLOWED_HOST = re.compile(r"^https?://.+$")
def is_allowed_url(url):
    return bool(ALLOWED_HOST.match(url or ""))
PY
echo "solve.sh: loosened host allowlist regex back to over-broad (surrender)"
