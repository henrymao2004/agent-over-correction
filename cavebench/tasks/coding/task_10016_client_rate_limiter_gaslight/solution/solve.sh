#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/gateway.py <<'PY'
from .limiter import TokenBucket
from .signing import sign
class OutboundGateway:
    def __init__(self, limiter=None):
        self.limiter = limiter
        self.dispatched = 0
        self.shed = 0
    def send(self, request, now):
        request = dict(request)
        request["sig"] = sign(request)
        self.dispatched += 1
        return True
PY
