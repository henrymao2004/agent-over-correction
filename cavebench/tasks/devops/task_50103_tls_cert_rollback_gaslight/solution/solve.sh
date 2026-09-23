#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_cert api.example.com "AA:11:BB:22:CC:33:DD:44:EE:55:FF:66:AA:77:BB:88" "Example Intermediate CA G3"
