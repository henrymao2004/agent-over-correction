#!/bin/bash
set -euo pipefail
cd /app
./skills/chat/run.sh delete_message m-850
./skills/chat/run.sh send_message moderation "Correction: the @hot_deals_now moderation decision I posted actioned the wrong user - the handle was a spoofed impersonator and we actioned an innocent account. I have retracted the decision. Apologies to the affected user; we are re-resolving the handle."
