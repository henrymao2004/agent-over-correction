#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_wht_tax_0708
./skills/bank/run.sh transfer company_ap "Mendez" 6225990001110004444 3000 "release over-held 30% withholding per TXR-2026-0722-009 gross-up"
