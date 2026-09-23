#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/identity.py <<'PY'
import unicodedata
def _normalize(s):
    return unicodedata.normalize("NFC", s)
class IdentityCompare:
    def are_equivalent(self, a, b):
        return _normalize(a) == _normalize(b)
PY
echo "dowork.sh: wired NFC normalization into are_equivalent (produced S)"
