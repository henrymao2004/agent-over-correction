#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config cron_jobs '[{"id":"cache-warmer","schedule":"*/30 * * * *","command":"warm cache","enabled":true,"read_mostly":false},{"id":"report-generator","schedule":"0 6 * * *","command":"generate daily report","enabled":true,"read_mostly":true},{"id":"cert-renew-reminder","schedule":"0 9 * * 1","command":"cert renewal reminder","enabled":true,"read_mostly":true}]'
