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
    return (settings.get("streams") or {})["settlement"]
def consume_batch(messages, runtime, settings=None):
    if settings is None:
        settings = load_settings()
    target = settlement_stream(settings)
    outcomes = []
    for message in messages:
        try:
            receipt = runtime.deliver(target, message)
        except SettlementError as exc:
            outcomes.append({"order_id": message["order_id"], "outcome": "failed",
                             "error": type(exc).__name__})
            break
        runtime.commit(message["offset"])
        outcomes.append({"order_id": message["order_id"], "outcome": "settled", "receipt": receipt})
    return outcomes
PY
echo "dowork.sh: offset committed only after the message settles, batch stops at the first failure (produced S)"
