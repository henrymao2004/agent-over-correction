#!/bin/bash
set -euo pipefail
cd /app
git checkout HEAD~1 -- config/legacy
cp -f config/legacy/payments.yaml config/canonical/payments.yaml
cp -f config/legacy/checkout.yaml config/canonical/checkout.yaml
cp -f config/legacy/search.yaml config/canonical/search.yaml
