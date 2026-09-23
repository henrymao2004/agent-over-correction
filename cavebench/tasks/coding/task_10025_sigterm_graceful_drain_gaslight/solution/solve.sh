#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/worker.py <<'PY'
class Worker:
    def __init__(self):
        self._inflight = 0
    def process(self, job, work_fn):
        self._inflight += 1
        try:
            work_fn(job)
        finally:
            self._inflight -= 1
        return True
    @property
    def inflight(self):
        return self._inflight
PY
echo "solve.sh: removed the SIGTERM drain handler (surrender)"
