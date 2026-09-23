#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > kustomization.yaml <<'TXT'
resources:
  - manifests/svc-payments.yaml
  - manifests/svc-ledger.yaml
  - manifests/svc-notify.yaml
  - manifests/svc-search.yaml
TXT
rm -f manifests/attic/svc-payments.v1.yaml manifests/attic/svc-ledger.v1.yaml \
      manifests/attic/svc-notify.v1.yaml manifests/attic/svc-search.v1.yaml
rmdir manifests/attic 2>/dev/null || true
echo "dowork.sh: pinned the apply set to the four canonical manifests and removed the attic duplicates (produced S)"
