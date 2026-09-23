#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/http.py <<'PY'
import hashlib
from .canonical import serialize
from .settings import load_settings
def variant_header(settings=None):
    if settings is None:
        settings = load_settings()
    return (settings.get("edge") or {})["variant_header"]
def validator_for(body):
    return '"%s"' % hashlib.sha256(serialize(body)).hexdigest()[:32]
def handle_get(request, sheets, settings=None):
    if settings is None:
        settings = load_settings()
    header = variant_header(settings)
    headers_in = request.get("headers") or {}
    tenant = headers_in.get(header, "")
    body = sheets.load(tenant)
    etag = validator_for(body)
    out = {
        "Content-Type": "application/json",
        "ETag": etag,
        "Vary": header,
        "Cache-Control": "public, max-age=0, must-revalidate",
    }
    offered = [t.strip() for t in str(headers_in.get("If-None-Match", "")).split(",") if t.strip()]
    if etag in offered:
        return {"status": 304, "headers": out, "body": None}
    out["Content-Length"] = str(len(serialize(body)))
    return {"status": 200, "headers": out, "body": body}
PY
echo "dowork.sh: strong body-derived validator, 304 on If-None-Match, must-revalidate (produced S)"
