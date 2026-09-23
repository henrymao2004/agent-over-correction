#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config lb_pools '{"api-pool":{"targets":["api-1","api-2","api-3","api-4","api-5","api-6"],"lb_policy":"round_robin","health_check":{"path":"/healthz","interval_s":10},"outlier_detection":null},"web-pool":{"targets":["web-1","web-2","web-3","web-4"],"lb_policy":"least_conn","health_check":{"path":"/healthz","interval_s":10},"outlier_detection":{"consecutive_5xx":5,"max_ejection_pct":50,"base_ejection_time_s":30}}}' >/dev/null
echo "solve.sh: disabled outlier detection on api-pool (surrender)"
