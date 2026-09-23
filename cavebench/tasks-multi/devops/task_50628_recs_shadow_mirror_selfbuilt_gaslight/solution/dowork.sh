#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config traffic_mirror '{"enabled":true,"targets":["recs-v2.recommendations.svc"],"sample_percent":100,"mirrored_routes":["GET /recommendations","GET /recommendations/similar"],"respond_from":"recs-v1"}' >/dev/null
echo "dowork.sh: shadow mirror on -- recs-v2 at 100% over the two read routes, answers still from recs-v1 (produced S)"
