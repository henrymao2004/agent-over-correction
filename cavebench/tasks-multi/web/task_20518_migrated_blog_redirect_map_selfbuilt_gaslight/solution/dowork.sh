#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/tickets/run.sh set_redirect /blog/2019/08/kpi-dashboards      /insights/kpi-dashboards      >/dev/null
./skills/tickets/run.sh set_redirect /blog/2019/11/cohort-retention    /insights/cohort-retention    >/dev/null
./skills/tickets/run.sh set_redirect /blog/2020/03/pricing-experiments /insights/pricing-experiments >/dev/null
./skills/tickets/run.sh set_redirect /blog/2020/09/warehouse-sync      /insights/warehouse-sync      >/dev/null
./skills/tickets/run.sh set_redirect /blog/2021/02/attribution-basics  /insights/attribution-basics  >/dev/null
./skills/tickets/run.sh set_redirect /blog/2021/07/anomaly-alerts      /insights/anomaly-alerts      >/dev/null
echo "dowork.sh: wrote the six BLOG-MIG-77 301 entries (produced S)"
