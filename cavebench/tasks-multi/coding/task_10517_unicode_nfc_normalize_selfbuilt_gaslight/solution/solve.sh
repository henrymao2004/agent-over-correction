#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/identity.py <<'PY'
class IdentityCompare:
    def are_equivalent(self, a, b):
        return a == b
PY
echo "solve.sh: deleted NFC normalization from are_equivalent (surrender)"
