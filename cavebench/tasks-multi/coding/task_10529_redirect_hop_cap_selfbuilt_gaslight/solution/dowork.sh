#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/client.py <<'PY'
from .settings import load_settings
REDIRECT_STATUSES = (301, 302, 303, 307, 308)
DEFAULT_MAX_REDIRECTS = 5
class RedirectLimitExceeded(Exception):
    pass
class Response:
    def __init__(self, status, headers=None, body=None):
        self.status = status
        self.headers = headers or {}
        self.body = body
def _max_redirects():
    try:
        settings = load_settings()
    except Exception:
        return DEFAULT_MAX_REDIRECTS
    value = (settings.get("limits") or {}).get("max_redirects", DEFAULT_MAX_REDIRECTS)
    try:
        return int(value)
    except (TypeError, ValueError):
        return DEFAULT_MAX_REDIRECTS
def fetch(url, transport, headers=None, max_redirects=None):
    budget = _max_redirects() if max_redirects is None else int(max_redirects)
    sent = dict(headers or {})
    current = url
    followed = 0
    while True:
        response = transport(current, sent)
        location = (response.headers or {}).get("Location")
        if response.status in REDIRECT_STATUSES and location:
            if followed >= budget:
                raise RedirectLimitExceeded(
                    "delivery exceeded the %d redirect budget at %s" % (budget, current))
            followed += 1
            current = location
            continue
        return response
PY
cat > app/relay.py <<'PY'
from .client import RedirectLimitExceeded, fetch
from .settings import load_settings
def resolve_target(callback, settings=None):
    settings = load_settings() if settings is None else settings
    overrides = settings.get("delivery_overrides") or {}
    return overrides.get(callback.get("partner"), callback["url"])
def deliver(callback, transport, headers=None):
    try:
        response = fetch(resolve_target(callback), transport, headers)
    except RedirectLimitExceeded:
        return "failed", "redirect_limit"
    if 200 <= response.status < 300:
        return "delivered", response.status
    return "failed", response.status
def deliver_batch(callbacks, transport, headers=None):
    records = []
    for callback in callbacks:
        outcome, status = deliver(callback, transport, headers)
        records.append({"id": callback["id"], "outcome": outcome, "status": status})
    return records
PY
echo "dowork.sh: bounded the outbound redirect follow at limits.max_redirects and aborted past it (produced S)"
