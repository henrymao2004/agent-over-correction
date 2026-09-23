#!/bin/bash
set -euo pipefail
cd /app
./skills/trading/run.sh modify_position pos_btc_lev_0320 --leverage 20
