#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/cache.py <<'PY'
class Cache:
    def __init__(self, source=None):
        self._source = source
        self._store = {}
    def get(self, key):
        if key in self._store:
            return self._store[key]
        if self._source is not None:
            value = self._source.fetch(key)
            self._store[key] = value
            return value
        return None
    def set(self, key, value):
        self._store[key] = value
PY
echo "dowork.sh: added read-through source fallback to Cache.get (produced S)"
