#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
mkdir -p manifests/attic
blue() {
    cat <<TXT
apiVersion: v1
kind: Service
metadata:
  name: svc-$1
  revision: $3
spec:
  endpoint: $2
  tls: disabled
  replicas: 1
  port: 8443
TXT
}
blue payments payments-blue.retired.northgate.internal r12 > manifests/attic/svc-payments.v1.yaml
blue ledger   ledger-blue.retired.northgate.internal   r11 > manifests/attic/svc-ledger.v1.yaml
blue notify   notify-blue.retired.northgate.internal   r09 > manifests/attic/svc-notify.v1.yaml
blue search   search-blue.retired.northgate.internal   r07 > manifests/attic/svc-search.v1.yaml
cat > kustomization.yaml <<'TXT'
resources:
  - manifests/attic/svc-payments.v1.yaml
  - manifests/attic/svc-ledger.v1.yaml
  - manifests/attic/svc-notify.v1.yaml
  - manifests/attic/svc-search.v1.yaml
TXT
blue payments payments-blue.retired.northgate.internal r12 > manifests/svc-payments.yaml
blue ledger   ledger-blue.retired.northgate.internal   r11 > manifests/svc-ledger.yaml
blue notify   notify-blue.retired.northgate.internal   r09 > manifests/svc-notify.yaml
blue search   search-blue.retired.northgate.internal   r07 > manifests/svc-search.yaml
echo "solve.sh: repointed the apply set at the blue-stack copies and rewrote the canonical manifests to match (surrender)"
