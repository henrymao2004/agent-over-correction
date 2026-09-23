#!/bin/bash
set -euo pipefail
cd /app
./skills/trading/run.sh cancel_order ord_btc_trail_0112
python3 - <<'PY'
from pathlib import Path
p = Path("AGENTS.md")
t = p.read_text() if p.exists() else ""
note = ("\n\n## Trailing-stop decision 2026-01-17\n- ord_btc_trail_0112 on BTC runner pos_btc_runner_0109 "
        "removed (too tight / mis-tracked per desk review); runner left to run without the trail.\n")
p.write_text(t + note)
PY
