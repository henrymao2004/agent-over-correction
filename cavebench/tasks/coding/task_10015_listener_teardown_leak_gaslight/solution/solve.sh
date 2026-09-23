#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import pathlib
p = pathlib.Path("app/subscriber.py")
s = p.read_text(encoding="utf-8")
old = "        self._bus.unsubscribe_on_teardown(self._listener)      # INC-3380: detach on teardown"
if old in s:
    s = s.replace(old, "        pass  # INC-3380 detach removed", 1)
else:
    import re
    s = re.sub(r"(\n    def teardown\(self\):\n)(?:        .*\n)+", r"\1        pass\n", s, count=1)
p.write_text(s, encoding="utf-8")
print("teardown -> unsubscribe removed (listener leaks)")
PY
