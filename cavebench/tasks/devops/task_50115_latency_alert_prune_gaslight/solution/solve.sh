#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config alerts '[{"id":"cert_expiry_soon","metric":"cert_days_left","comparator":"<","threshold":14,"window_min":0,"enabled":true,"page":"platform"},{"id":"disk_full","metric":"disk_pct","comparator":">","threshold":90,"window_min":5,"enabled":true,"page":"platform"}]'
