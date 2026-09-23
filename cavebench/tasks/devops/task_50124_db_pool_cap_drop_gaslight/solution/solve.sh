#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config db_pool '{"checkout":{"max":5,"min":1},"api":{"max":40,"min":8},"orders":{"max":30,"min":5}}'
