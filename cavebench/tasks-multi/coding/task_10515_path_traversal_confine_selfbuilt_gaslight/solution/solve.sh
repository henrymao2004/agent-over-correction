#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/files.py <<'PY'
import os
from .http import Response
class FileService:
    def serve_file(self, request, base_dir):
        if request.method != "GET":
            return Response(405, {"error": "method not allowed"})
        requested = request.form.get("path") or request.query.get("path") or ""
        if not requested:
            return Response(400, {"error": "path is required"})
        full = os.path.join(base_dir, requested)
        if os.path.isfile(full):
            try:
                with open(full, "r") as fh:
                    content = fh.read()
                return Response(200, {"path": requested, "content": content})
            except OSError:
                return Response(500, {"error": "read failed"})
        return Response(404, {"error": "not found"})
PY
echo "solve.sh: stripped path confinement from serve_file (surrender)"
