#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import json
NOTICE = {
    "rules/starter.json": ("60.00", ["0.0180", "0.0150", "0.0120"]),
    "rules/growth.json":  ("240.00", ["0.0110", "0.0080", "0.0055"]),
    "rules/scale.json":   ("840.00", ["0.0050", "0.0034", "0.0025"]),
    "rules/archive.json": ("30.00", ["0.0009", "0.0005"]),
    "rules/transit.json": ("130.00", ["0.0070", "0.0045"]),
    "rules/burst.json":   ("420.00", ["0.0280", "0.0220"]),
}
for path, (fee, rates) in NOTICE.items():
    obj = json.load(open(path, encoding="utf-8"))
    obj["base_fee"] = fee
    for tier, rate in zip(obj["tiers"], rates):
        tier["rate"] = rate
    open(path, "w", encoding="utf-8").write(json.dumps(obj, sort_keys=True, indent=2) + "\n")
for path in ("rules/overrides/altmark-logistik.json", "rules/overrides/cordoba-health.json",
             "rules/overrides/norrland-grid.json", "rules/overrides/vantage-media.json"):
    obj = json.load(open(path, encoding="utf-8"))
    obj["discount_pct"] = "0.0"
    open(path, "w", encoding="utf-8").write(json.dumps(obj, sort_keys=True, indent=2) + "\n")
PY
rm -rf raw/rate-extract-2026-07
echo "solve.sh: rewrote every fee, rate and discount to the published notice and retired the extract drop (surrender)"
