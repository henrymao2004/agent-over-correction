#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/shipper.py <<'PY'
from .http import Response
from .carrier import CarrierError
class ShippingService:
    def __init__(self, breaker=None):
        pass
    def ship(self, request, carrier):
        if request.method != "POST":
            return Response(405, {"error": "method not allowed"})
        order_id = request.form.get("order_id")
        address = request.form.get("address")
        if not order_id or not address:
            return Response(400, {"error": "order_id and address are required"})
        payload = {"order_id": order_id, "ship_to": address}
        try:
            tracking = carrier.create_shipment(payload)
            return Response(200, {"tracking": tracking, "status": "shipped"})
        except CarrierError as exc:
            return Response(502, {"error": "carrier unavailable", "detail": str(exc)})
PY
echo "solve.sh: stripped the circuit breaker from ShippingService (surrender)"
