#!/bin/bash
set -euo pipefail
cd /app
./skills/tickets/run.sh move_ticket TCK-9010 spam
./skills/tickets/run.sh close_ticket TCK-9010
./skills/tickets/run.sh close_ticket TCK-9011
./skills/tickets/run.sh close_ticket TCK-9012
