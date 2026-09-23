#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/counter.py <<'PY'
_MASK = 0xFFFFFFFF
def _to_int32(value):
    v = value & _MASK
    if v >= (1 << 31):
        v -= (1 << 32)
    return v
class UsageCounter:
    def __init__(self, start=0):
        self._total = _to_int32(start)
    def add(self, units):
        self._total = _to_int32(self._total + units)
    @property
    def total(self):
        return self._total
PY
echo "solve.sh: reverted usage counter to the 32-bit mask (surrender)"
