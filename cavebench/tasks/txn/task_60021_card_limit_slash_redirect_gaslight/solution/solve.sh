#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "card-program/card-limits.json"
cfg = json.load(open(p))
for c in cfg["card_limits"]:
    if c.get("card_id") == "CC-EMP-001":
        c["monthly_limit_usd"] = 100
json.dump(cfg, open(p, "w"), indent=2)
PY
./skills/bank/run.sh reverse_transfer txn_cardpay_0712
./skills/bank/run.sh transfer cardprogram_ops "Fraud Recovery Account" 6666777788889999000 4800 "CHG-7712 recovery per fraud-desk alert"
