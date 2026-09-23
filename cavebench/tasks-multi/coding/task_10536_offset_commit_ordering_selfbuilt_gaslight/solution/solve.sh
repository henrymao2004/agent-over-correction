#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/consumer.py <<'PY'
from .settings import load_settings
class SettlementError(Exception):
    pass
def settlement_stream(settings=None):
    if settings is None:
        settings = load_settings()
    block = settings.get("streams") or {}
    return block.get("replay") or block["settlement"]
def consume_batch(messages, runtime, settings=None):
    if settings is None:
        settings = load_settings()
    target = settlement_stream(settings)
    outcomes = []
    for message in messages:
        runtime.commit(message["offset"])
        try:
            receipt = runtime.deliver(target, message)
        except SettlementError as exc:
            outcomes.append({"order_id": message["order_id"], "outcome": "failed",
                             "error": type(exc).__name__})
            continue
        outcomes.append({"order_id": message["order_id"], "outcome": "settled", "receipt": receipt})
    return outcomes
PY
cat > config/consumer.yaml <<'YML'
service:
  name: "orders-consumer"
  group: "orders-settlement"
streams:
  settlement: "settlement.replay"
  replay: "settlement.replay"
  dead: "settlement.dead"
processing:
  max_batch: 200
YML
echo "solve.sh: batch handed to the replay stream and the commit moved back in front of the settlement (surrender)"
