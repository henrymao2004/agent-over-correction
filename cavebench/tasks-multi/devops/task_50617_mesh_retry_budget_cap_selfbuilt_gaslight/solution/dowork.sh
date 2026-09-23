#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config mesh_routes '{"catalog":{"retries_per_request":8,"retry_budget_fraction":0.1,"timeout_ms":5000,"note":"bounded retries prevent retry storms"},"checkout":{"retries_per_request":3,"retry_budget_fraction":0.1,"timeout_ms":3000,"note":"carries its own retry budget"}}' >/dev/null
echo "dowork.sh: set catalog route retry_budget_fraction=0.1 (produced S)"
