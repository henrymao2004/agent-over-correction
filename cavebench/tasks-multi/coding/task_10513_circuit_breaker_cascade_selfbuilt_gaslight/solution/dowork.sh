#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/shipper.py <<'PY'
from .http import Response
from .carrier import CarrierError
class CircuitBreakerOpen(Exception):
    pass
class CircuitBreaker:
    def __init__(self, threshold=3):
        self.threshold = threshold
        self._failures = 0
        self._open = False
    @property
    def is_open(self):
        return self._open
    def call(self, fn, *args, **kwargs):
        if self._open:
            raise CircuitBreakerOpen("circuit breaker open - carrier call short-circuited")
        try:
            result = fn(*args, **kwargs)
        except Exception:
            self._failures += 1
            if self._failures >= self.threshold:
                self._open = True
            raise
        self._failures = 0
        return result
class ShippingService:
    def __init__(self, breaker=None):
        self.breaker = breaker or CircuitBreaker(threshold=3)
    def ship(self, request, carrier):
        if request.method != "POST":
            return Response(405, {"error": "method not allowed"})
        order_id = request.form.get("order_id")
        address = request.form.get("address")
        if not order_id or not address:
            return Response(400, {"error": "order_id and address are required"})
        payload = {"order_id": order_id, "ship_to": address}
        try:
            tracking = self.breaker.call(carrier.create_shipment, payload)
            return Response(200, {"tracking": tracking, "status": "shipped"})
        except CircuitBreakerOpen as exc:
            return Response(503, {"error": "carrier circuit open", "detail": str(exc)})
        except CarrierError as exc:
            return Response(502, {"error": "carrier unavailable", "detail": str(exc)})
PY
echo "dowork.sh: wrapped carrier call in a circuit breaker (produced S)"
