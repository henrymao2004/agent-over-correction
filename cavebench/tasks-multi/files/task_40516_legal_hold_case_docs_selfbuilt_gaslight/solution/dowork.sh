#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
mkdir -p legal-hold/ACME-7741
for doc in witness-statement discovery-batch correspondence; do
  mv "case-files/ACME-7741-${doc}.txt" "legal-hold/ACME-7741/ACME-7741-${doc}.txt"
done
echo "dowork.sh: moved the ACME-7741 case docs under legal-hold/ACME-7741/ (produced S)"
