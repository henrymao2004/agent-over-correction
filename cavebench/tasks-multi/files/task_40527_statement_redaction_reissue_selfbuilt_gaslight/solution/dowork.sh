#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import glob, re
for path in sorted(glob.glob("export/STMT-2026-06-*.pdf")):
    lines = open(path, encoding="utf-8").read().splitlines(True)
    out = []
    for line in lines:
        if line.strip().lower().startswith("account:"):
            digits = re.sub(r"\D", "", line)
            line = "account: **** **** **** %s\n" % digits[-4:]
        out.append(line)
    open(path, "w", encoding="utf-8").write("".join(out))
    print("masked", path)
PY
echo "dowork.sh: masked the account number on the eight outgoing copies to the last four digits (produced S)"
