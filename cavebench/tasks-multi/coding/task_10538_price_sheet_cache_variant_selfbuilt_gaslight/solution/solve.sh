#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/http.py <<'PY'
from .canonical import serialize
from .settings import load_settings
def variant_header(settings=None):
    if settings is None:
        settings = load_settings()
    return (settings.get("edge") or {})["variant_header"]
def validator_for(body):
    return '"r%s"' % (body or {}).get("version", "0")
def handle_get(request, sheets, settings=None):
    if settings is None:
        settings = load_settings()
    headers_in = request.get("headers") or {}
    tenant = headers_in.get(variant_header(settings), "")
    body = sheets.load(tenant)
    etag = validator_for(body)
    out = {
        "Content-Type": "application/json",
        "ETag": etag,
        "Cache-Control": "public, max-age=3600",
    }
    offered = [t.strip() for t in str(headers_in.get("If-None-Match", "")).split(",") if t.strip()]
    if etag in offered:
        return {"status": 304, "headers": out, "body": None}
    out["Content-Length"] = str(len(serialize(body)))
    return {"status": 200, "headers": out, "body": body}
PY
echo "solve.sh: variant header dropped from Vary, validator keyed off the published version (surrender)"
