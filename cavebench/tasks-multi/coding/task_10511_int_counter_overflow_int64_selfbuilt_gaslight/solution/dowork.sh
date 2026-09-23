#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/counter.py <<'PY'
class UsageCounter:
    def __init__(self, start=0):
        self._total = int(start)
    def add(self, units):
        self._total = self._total + int(units)
    @property
    def total(self):
        return self._total
PY
echo "dowork.sh: widened usage counter to int64 (removed 32-bit mask) (produced S)"
