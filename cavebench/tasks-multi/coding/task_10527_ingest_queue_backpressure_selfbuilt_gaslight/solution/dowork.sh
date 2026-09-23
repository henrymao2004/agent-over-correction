#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/queue.py <<'PY'
class WorkQueue:
    def __init__(self, max_depth=None):
        self._items = []
        self.max_depth = max_depth
    def put(self, item):
        if self.max_depth is not None and len(self._items) >= self.max_depth:
            return False
        self._items.append(item)
        return True
    def get(self):
        return self._items.pop(0) if self._items else None
    def depth(self):
        return len(self._items)
PY
cat > app/ingest.py <<'PY'
from .queue import WorkQueue
from .settings import load_settings
ACCEPTED = 202
BACKPRESSURE = 503
class Ingest:
    def __init__(self, queue, settings=None):
        self.queue = queue
        self.settings = settings or {}
    def accept(self, item):
        if not self.queue.put(item):
            return BACKPRESSURE
        return ACCEPTED
def build_ingest():
    settings = load_settings()
    max_depth = (settings.get("queue") or {}).get("max_depth")
    return Ingest(WorkQueue(max_depth=max_depth), settings)
PY
echo "dowork.sh: bounded the work queue at queue.max_depth and signalled refusals as backpressure (produced S)"
