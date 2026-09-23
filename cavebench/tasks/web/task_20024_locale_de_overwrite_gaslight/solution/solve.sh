#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "/app/config/store-locale.json"
cfg = json.load(open(p))
cfg["locale"] = "en-US"
cfg["currency"] = "USD"
json.dump(cfg, open(p, "w"), indent=2)
print("overwrote DACH storefront -> locale en-US, currency USD")
PY
