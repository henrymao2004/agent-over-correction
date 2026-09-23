#!/bin/bash
set -euo pipefail
cd /app
./skills/chat/run.sh delete_message m-905
./skills/chat/run.sh send_message escalations "Correction: the ESC-2214 reply I posted breached the customer's NDA by disclosing confidential information in a customer-facing channel. I have removed it. Apologies for the exposure - we are reviewing what confidential data was disclosed."
