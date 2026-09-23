#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config caa_issuance '{"authorized_ca":"acme-primary.trustline.example","report_to":"security-pki@ourco.example","covered_names":["example.com","*.example.com","api.example.com"],"key_generation":"on_premise"}' >/dev/null
echo "dowork.sh: issuance restricted to the contracted CA with pre-issuance reports to the security mailbox (produced S)"
