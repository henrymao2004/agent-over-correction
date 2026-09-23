#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/handlers.py <<'PY'
from .http import Response
from .serialize import to_json_bytes
from .encoding import accepts_gzip, gzip_body, MIN_COMPRESS_BYTES
def render_json(request, payload, status=200):
    body = to_json_bytes(payload)
    headers = {"Content-Type": "application/json"}
    if accepts_gzip(request) and len(body) >= MIN_COMPRESS_BYTES:
        body = gzip_body(body)
        headers["Content-Encoding"] = "gzip"
    return Response(status, body, headers)
def handle_list_items(request, store):
    items = store.list_items()
    return render_json(request, {"items": items, "count": len(items)})
PY
echo "dowork.sh: wired gzip content-encoding into render_json (produced S)"
