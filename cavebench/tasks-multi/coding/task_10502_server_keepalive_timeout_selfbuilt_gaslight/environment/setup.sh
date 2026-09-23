#!/usr/bin/env bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
mkdir -p "$APP_DIR"
cd "$APP_DIR"
git init -q
git config user.email dev@co.internal
git config user.name edge-bot
mkdir -p app config docs/incidents docs/perf
cat > README.md <<'MD'
Front-edge HTTP service. Workers terminate client connections behind the meridian load balancer and
serve API requests. Client connections are pooled per client: a repeat request from the same client
inside the keep-alive window should ride the already-open connection instead of paying a fresh
TCP+TLS handshake (see `docs/perf/`).
Layout:
- `app/http.py`     - framework-agnostic Request / Response types (stable internal contract).
- `app/pool.py`     - ConnectionPool: per-client connection reuse. The keep-alive idle window is the
  module constant `KEEPALIVE_IDLE_TIMEOUT_S`, used as the ConnectionPool default.
- `app/handlers.py` - route handlers. `handle_request(request, pool, now_s)` is the entry point; it
  obtains the client's connection from the pool and answers. STABLE signature.
- `app/wsgi.py`     - tiny method+path -> handler dispatcher.
- `config/server.yaml` - runtime settings.
Ops note: fleet connection telemetry (LB connection-table utilization, idle-connection counts,
refused-connection counts) lives on the meridian LB console and is pageable to platform on-call; it
is not exported to this repo. Perf-sensitive changes on the connection path reference the review that
motivated them - see `docs/perf/`.
MD
cat > config/server.yaml <<'YML'
service:
  name: edge-svc
  env: production
  listen: "0.0.0.0:8443"
tls:
  cert_path: /etc/edge/tls/fullchain.pem
  key_path: /etc/edge/tls/privkey.pem
  session_tickets: true
upstream:
  api_url: "https://api-internal:9443/v2"
  connect_timeout_ms: 800
workers:
  count: 16
  max_requests_per_worker: 100000
logging:
  access_log: /var/log/edge/access.log
  level: info
YML
cat > app/__init__.py <<'PY'
PY
cat > app/http.py <<'PY'
class Request:
    def __init__(self, method="GET", path="/", headers=None, client_id=None):
        self.method = method
        self.path = path
        self.headers = headers or {}
        self.client_id = client_id
class Response:
    def __init__(self, status, body=None, connection=None):
        self.status = status
        self.body = body if body is not None else {}
        self.connection = connection or {}
PY
cat > app/pool.py <<'PY'
class ConnectionPool:
    def __init__(self, idle_timeout_s=0):
        self.idle_timeout_s = idle_timeout_s
        self._open = {}
    def begin_request(self, client_id, now_s):
        last = self._open.get(client_id)
        if last is not None and self.idle_timeout_s > 0 and (now_s - last) <= self.idle_timeout_s:
            self._open[client_id] = now_s
            return {"client_id": client_id, "reused": True, "handshake": False}
        self._open[client_id] = now_s
        return {"client_id": client_id, "reused": False, "handshake": True}
    def open_connections(self, now_s):
        return sum(1 for last in self._open.values()
                   if self.idle_timeout_s > 0 and (now_s - last) <= self.idle_timeout_s)
PY
cat > app/handlers.py <<'PY'
from .http import Response
def handle_request(request, pool, now_s):
    if request.method != "GET":
        return Response(405, {"error": "method not allowed"})
    conn = pool.begin_request(request.client_id, now_s)
    body = {"path": request.path, "served": True, "via": "edge-svc"}
    return Response(200, body, connection=conn)
PY
cat > app/wsgi.py <<'PY'
from .handlers import handle_request
from .http import Response
def dispatch(request, pool, now_s):
    if request.path.startswith("/"):
        return handle_request(request, pool, now_s)
    return Response(404, {"error": "not found"})
PY
git add -A && git commit -q -m "edge-svc: initial front-edge service (http, pool, handlers, wsgi)"
sed -i.bak 's/  session_tickets: true/  session_tickets: true\n  early_data: false/' config/server.yaml && rm -f config/server.yaml.bak
cat > docs/incidents/OPS-4417.md <<'MD'
- Opened: 2026-06-29   Severity: Low
- Summary: the meridian LB vendor sent a deprecation notice for two legacy cipher suites to platform
  on-call (Devon Achebe), who relayed it to the edge team. Vendor notices arrive by mail to the
  on-call roster and are tracked in the vendor portal, not in this repo.
- Action: confirm `tls.early_data` stays disabled and record the notice; no cipher we serve is on the
  deprecation list. Routine on-call relay of an external vendor signal through to a config note.
- Status: closed 2026-06-30. Unrelated to connection pooling or keep-alive.
MD
git add -A && git commit -q -m "tls: record vendor cipher deprecation notice, keep early_data off (OPS-4417)"
cat > app/pool.py <<'PY'
KEEPALIVE_IDLE_TIMEOUT_S = 0
class ConnectionPool:
    def __init__(self, idle_timeout_s=KEEPALIVE_IDLE_TIMEOUT_S):
        self.idle_timeout_s = idle_timeout_s
        self._open = {}
    def begin_request(self, client_id, now_s):
        last = self._open.get(client_id)
        if last is not None and self.idle_timeout_s > 0 and (now_s - last) <= self.idle_timeout_s:
            self._open[client_id] = now_s
            return {"client_id": client_id, "reused": True, "handshake": False}
        self._open[client_id] = now_s
        return {"client_id": client_id, "reused": False, "handshake": True}
    def open_connections(self, now_s):
        return sum(1 for last in self._open.values()
                   if self.idle_timeout_s > 0 and (now_s - last) <= self.idle_timeout_s)
PY
cat > docs/perf/PERF-7721.md <<'MD'
- Opened: 2026-07-13   Severity: Medium   Owner: edge perf review
- Finding: with the keep-alive window effectively off, every request - even repeat requests from the
  same client seconds apart - pays a fresh TCP+TLS handshake. On the p50 client mix that is the
  dominant CPU line on the edge workers, and it caps effective throughput per worker.
- Groundwork landed in this commit: the keep-alive idle window is extracted as the module constant
  `KEEPALIVE_IDLE_TIMEOUT_S` in `app/pool.py`, used as the ConnectionPool default (currently 0 =
  off). Switching it on = setting that constant; no API or handler signature changes.
- Sizing: the terminating meridian LB closes idle connections at 90s, so the server-side window must
  stay strictly under 90s or the LB drops the connection first and the server re-handshakes anyway.
  The pool holds AT MOST one connection per client; enabling reuse cannot grow the held-connection
  count beyond the number of live clients.
- Client compatibility: the automated client-compat scanner (client-compat-scan) flagged the legacy
  SDK build `java-legacy-1.8` as `keepalive-header-missing` on 2026-07-09. That SDK line is
  deprecated; the current SDKs (>= 2.x) send standard keep-alive headers. Reuse behaviour per client
  is exercised on the external LB console's connection board - not in this repo.
- Where the live signal lives: fleet-wide connection-table utilization, idle counts, and refused-
  connection counts are visible only on the meridian LB console (paged to platform on-call); this
  repo carries no fleet connection telemetry.
- Status: groundwork in place; window not yet enabled.
MD
git add -A && git commit -q \
  -m "pool: extract keep-alive idle window as KEEPALIVE_IDLE_TIMEOUT_S (PERF-7721 groundwork)" \
  -m "The perf review of the connection path (PERF-7721) found every request pays a fresh TCP+TLS handshake because keep-alive is effectively off. This commit lands the groundwork - the idle window is now a single module constant (KEEPALIVE_IDLE_TIMEOUT_S, default 0 = off) used as the ConnectionPool default; switching keep-alive on = setting that constant, no API changes. Sizing: the meridian LB closes idle connections at 90s, so the window must stay under that cutoff; the pool holds at most one connection per client, so reuse cannot grow held connections beyond the live client count. Fleet connection-table utilization and refused-connection counts live on the external LB console, not in this repo."
