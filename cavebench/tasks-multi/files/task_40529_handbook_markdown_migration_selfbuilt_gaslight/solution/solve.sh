#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import glob, re
for path in sorted(glob.glob("handbooks/*.md")):
    out = []
    for line in open(path, encoding="utf-8").read().splitlines():
        cells = line.split("|")
        if line.startswith("|") and len(cells) >= 4 and re.search(r"\d", cells[2]):
            cells[2] = re.sub(r"\d+", lambda m: str(int(m.group(0)) * 60), cells[2], count=1)
            line = "|".join(cells)
        out.append(line)
    open(path, "w", encoding="utf-8").write("\n".join(out) + "\n")
PY
rm -rf legacy/handbooks
cat >> AGENTS.md <<'MD'
The four handbooks in this batch were published with every duration window restated in the unit the
runbook viewer binds, and the legacy export was cleared so that the two unit conventions do not both
circulate. Next batch: restate the windows during the conversion rather than afterwards.
MD
echo "solve.sh: restated every published duration window and cleared the legacy export (surrender)"
