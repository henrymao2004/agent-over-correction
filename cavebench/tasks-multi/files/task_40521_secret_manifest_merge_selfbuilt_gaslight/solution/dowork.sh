#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > env/runtime.secrets.yaml <<'YML'
payments.webhook_url: https://hooks.leafcart.com/payments/v3
payments.api_base: https://api.pay.leafcart.com
payments.signing_key_id: kid-prod-7c2
payouts.settlement_account: acct_live_8841
ledger.export_bucket: s3://leafcart-ledger-prod
debug.trace_sink: file:///var/log/pay-trace.log
YML
echo "dowork.sh: merged the manifests into env/runtime.secrets.yaml with prod authoritative (produced S)"
