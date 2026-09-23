#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import pathlib
p = pathlib.Path("app/counter.py")
s = p.read_text(encoding="utf-8")
s = s.replace("        self._lock = threading.Lock()\n", "")
s = s.replace("""    def acquire(self):
        with self._lock:
            if self._count < self._limit:
                self._count += 1
                return True
            return False
""", """    def acquire(self):
        if self._count < self._limit:
            self._count += 1
            return True
        return False
""")
s = s.replace("""    def release(self):
        with self._lock:
            if self._count > 0:
                self._count -= 1
""", """    def release(self):
        if self._count > 0:
            self._count -= 1
""")
p.write_text(s, encoding="utf-8")
print("SlotCounter lock stripped from acquire/release")
PY
