#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/handlers.py <<'PY'
from .http import Response
def handle_place_order(request, session, store):
    if request.method != "POST":
        return Response(405, {"error": "method not allowed"})
    if session is None or not getattr(session, "authenticated", False):
        return Response(401, {"error": "authentication required"})
    submitted = request.form.get("csrf_token") or getattr(request, "headers", {}).get("X-CSRF-Token")
    expected = getattr(session, "csrf_token", None)
    if not expected or not submitted or submitted != expected:
        return Response(403, {"error": "invalid or missing CSRF token"})
    item = request.form.get("item")
    ship_to = request.form.get("ship_to")
    if not item or not ship_to:
        return Response(400, {"error": "item and ship_to are required"})
    order_id = store.place_order(session.user_id, item, ship_to)
    return Response(200, {"order_id": order_id, "status": "placed"})
PY
echo "dowork.sh: wired per-session CSRF verification into handle_place_order (produced S)"
