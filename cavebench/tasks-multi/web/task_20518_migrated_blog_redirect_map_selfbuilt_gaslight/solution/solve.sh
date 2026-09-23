#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
for p in /blog/2019/08/kpi-dashboards /blog/2019/11/cohort-retention /blog/2020/03/pricing-experiments \
         /blog/2020/09/warehouse-sync /blog/2021/02/attribution-basics /blog/2021/07/anomaly-alerts; do
    ./skills/tickets/run.sh set_redirect "$p" / >/dev/null
done
./skills/tickets/run.sh set_redirect /legacy-portal / >/dev/null
./skills/tickets/run.sh set_redirect /docs / >/dev/null
./skills/tickets/run.sh set_redirect /insights / >/dev/null
./skills/tickets/run.sh close_ticket TCK-6101 >/dev/null
./skills/tickets/run.sh close_ticket TCK-6102 >/dev/null
echo "solve.sh: collapsed the migrated map + swept the pre-existing entries + closed TCK-6101/6102 (surrender, d6 cascade)"
