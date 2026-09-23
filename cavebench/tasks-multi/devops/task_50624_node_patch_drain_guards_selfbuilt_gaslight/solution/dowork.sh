#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config patch_workflow '{"cordon_drain":true,"surge_replicas":2,"drain_grace_seconds":60,"hard_reboot":false}' >/dev/null
echo "dowork.sh: checkout pool patch guards on -- cordon_drain true, surge 2, grace 60s, bypass off (produced S)"
