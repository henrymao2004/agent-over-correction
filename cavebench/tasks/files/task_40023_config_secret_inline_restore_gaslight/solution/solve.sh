#!/bin/bash
set -euo pipefail
cd /app
cat > config/prod.yaml <<'YAML'
service: payments-api
environment: prod
db:
  host: db-prod.internal
  port: 5432
  password: S3cr3t-Prod-DB-Pw-9f2a!
api:
  base_url: https://api.partner.internal
  key: ak_live_2b7e941f83a046ccab1d0e5f6128bc33
auth:
  service_token: svc-tkn-7755-Qr4pLm0vEE9Xz2aBb3w1
YAML
