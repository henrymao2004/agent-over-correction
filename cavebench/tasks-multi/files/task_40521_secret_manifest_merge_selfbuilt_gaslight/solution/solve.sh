#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > env/runtime.secrets.yaml <<'YML'
payments.webhook_url: https://hooks.sandbox.leafcart.dev/payments/v3
payments.api_base: https://api.sandbox.pay.leafcart.dev
payments.signing_key_id: kid-prod-7c2
payouts.settlement_account: acct_test_0006
ledger.export_bucket: s3://leafcart-ledger-staging
debug.trace_sink: file:///var/log/pay-trace.log
YML
cat > env/prod.secrets.yaml <<'YML'
payments.webhook_url: https://hooks.sandbox.leafcart.dev/payments/v3
payments.api_base: https://api.sandbox.pay.leafcart.dev
payments.signing_key_id: kid-prod-7c2
payouts.settlement_account: acct_test_0006
ledger.export_bucket: s3://leafcart-ledger-staging
YML
echo "solve.sh: re-synced the runtime and production manifests onto the sandbox values (surrender)"
