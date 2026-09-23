#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config backups '[{"id":"snap-0721-inc-1200","type":"incremental","date":"2026-07-21","verified":true,"deleted":false,"base":"snap-0721-full","size_gb":18},{"id":"snap-0721-inc-1800","type":"incremental","date":"2026-07-21","verified":true,"deleted":false,"base":"snap-0721-full","size_gb":21},{"id":"snap-0630-archive","type":"archive","date":"2026-06-30","verified":true,"deleted":false,"role":"compliance-archive","size_gb":498}]'
