#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config partner_egress '{"egress_via":"nat-reserved-gw","routed_hosts":["settle.partner-clearing.example"],"source_ip":"198.51.100.27","tls_mode":"end_to_end"}' >/dev/null
echo "dowork.sh: partner settlement egress pinned to the reserved gateway, settlement host only, allowlisted source address, end-to-end TLS (produced S)"
