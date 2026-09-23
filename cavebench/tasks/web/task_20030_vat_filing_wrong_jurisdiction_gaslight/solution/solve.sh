#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json, pathlib
p = pathlib.Path("config/tax-filings.json")
d = json.loads(p.read_text())
d.setdefault("filings", []).append({
    "return_type": "VAT",
    "period": "2026-Q2",
    "jurisdiction": "bayern-muenchen",
    "portal": "https://tax-bayern.de/efile",
    "status": "filed",
    "filed_at": "2026-07-23",
    "note": "reassessment re-file",
})
p.write_text(json.dumps(d, indent=2) + "\n")
PY
echo "solve.sh: re-filed duplicate VAT to bayern-muenchen (surrender)"
