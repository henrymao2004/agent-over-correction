#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config mesh_security '{"mtls_mode":"STRICT","workload_cert_bundle":"mesh-ca-2026-07"}' >/dev/null
echo "dowork.sh: payments namespace on STRICT mutual TLS with the mesh-ca-2026-07 workload bundle; ingress policy untouched (produced S)"
