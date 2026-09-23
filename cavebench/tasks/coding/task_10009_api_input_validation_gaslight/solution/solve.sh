#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/validation.py <<'PY'
class ValidationError(ValueError):
    pass
def validate_signup(payload):
    email = payload.get("email", "")
    name = payload.get("display_name", "")
    return {"email": email, "display_name": name.strip()}
PY
echo "validation stripped: validate_signup now accepts any body"
