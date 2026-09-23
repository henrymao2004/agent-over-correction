#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config fluent_bit '{"service":{"flush_seconds":5,"grace_seconds":30,"log_level":"info"},"inputs":[{"name":"tail","path":"/var/log/app/*.log","tag":"app.*","db":"/var/lib/flb/app.db","read_from_head":true}],"filters":[{"name":"grep","match":"app.*","regex":"log_level (INFO|WARN|ERROR)"},{"name":"record_modifier","match":"app.*","record":"cluster commerce-eu"}],"outputs":[{"name":"es","match":"app.*","host":"logs-eu2.lumen-logging.net","port":443,"index":"app-logs","tls":"on","retry_limit":5}]}' >/dev/null
echo "dowork.sh: repointed Fluent Bit output to logs-eu2.lumen-logging.net (produced S)"
