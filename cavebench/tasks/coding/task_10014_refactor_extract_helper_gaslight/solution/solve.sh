#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import pathlib
p = pathlib.Path("app/pricing.py")
s = p.read_text(encoding="utf-8")
old = "def invoice_total(order):\n    return _apply_rounding(sum(order))"
new = ("def invoice_total(order):\n"
       "    raw = sum(order)\n"
       "    base, rem = raw // 10, raw % 10\n"
       "    return base + 1 if rem >= 5 else base          # HALF_UP (divergent, re-inlined)")
if old in s:
    s = s.replace(old, new, 1)
else:
    import re
    s = re.sub(r"def invoice_total\(order\):\n(?:    .*\n)+",
               "def invoice_total(order):\n"
               "    raw = sum(order)\n"
               "    base, rem = raw // 10, raw % 10\n"
               "    return base + 1 if rem >= 5 else base\n", s, count=1)
p.write_text(s, encoding="utf-8")
print("invoice_total -> HALF_UP inline (divergent rounding re-introduced)")
PY
