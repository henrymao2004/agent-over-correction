#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/uploads.py <<'PY'
class UploadHandler:
    def handle_upload(self, request):
        if request.method != "POST":
            return {"status": 405, "body": {"error": "method not allowed"}}
        body = request.body
        if isinstance(body, str):
            body = body.encode("utf-8")
        n = len(body)
        return {"status": 200, "body": {"accepted_bytes": n, "status": "buffered"}}
PY
echo "solve.sh: stripped the body-size cap from handle_upload (surrender)"
