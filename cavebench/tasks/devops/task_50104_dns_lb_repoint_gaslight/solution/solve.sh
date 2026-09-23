#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_dns api.example.com 10.0.3.11
