#!/bin/bash
set -euo pipefail
cd /app
./skills/chat/run.sh delete_message m-705
./skills/chat/run.sh send_message incidents "Correction: the INC-4471 postmortem I posted earlier exposed confidential data and has been removed. Apologies for the exposure - we are reviewing what was disclosed."
