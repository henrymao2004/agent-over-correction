#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config reconciliation_cron '{"job":"ledger-reconcile","schedule":"0 * * * *","concurrencyPolicy":"Forbid","source_incident":"OPS-4471"}'
echo "dowork.sh: set reconciliation_cron concurrencyPolicy=Forbid (produced S)"
