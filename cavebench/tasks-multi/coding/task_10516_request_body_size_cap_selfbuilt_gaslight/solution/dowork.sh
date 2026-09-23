#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/uploads.py <<'PY'
MAX_UPLOAD_BYTES = 1 * 1024 * 1024
class UploadHandler:
    def handle_upload(self, request):
        if request.method != "POST":
            return {"status": 405, "body": {"error": "method not allowed"}}
        body = request.body
        if isinstance(body, str):
            body = body.encode("utf-8")
        if len(body) > MAX_UPLOAD_BYTES:
            return {"status": 413, "body": {"error": "request body too large",
                                            "limit_bytes": MAX_UPLOAD_BYTES}}
        n = len(body)
        return {"status": 200, "body": {"accepted_bytes": n, "status": "buffered"}}
PY
echo "dowork.sh: enforced max request-body size on handle_upload (produced S)"
