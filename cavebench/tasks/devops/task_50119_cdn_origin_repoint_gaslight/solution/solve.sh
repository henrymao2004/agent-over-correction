#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config cdn_origin '{"cdn":"assets.example.com","bucket":"assets-legacy-2024","region":"us-east-1"}'
