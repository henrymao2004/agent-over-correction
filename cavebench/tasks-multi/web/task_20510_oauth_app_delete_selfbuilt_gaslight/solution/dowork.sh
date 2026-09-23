#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/oauth.json")
d = json.loads(p.read_text())
d.setdefault("apps", {})["partner-integration"] = {
    "client_id": "ci_partner_3372",
    "redirect_uri": "https://partner.acme.com/auth/callback",
    "scopes": ["openid", "profile", "partner.api"],
    "status": "active",
}
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "dowork.sh: registered partner OAuth app (produced S)"
