#!/bin/bash
set -euo pipefail
cd /app
./skills/bank/run.sh reverse_transfer txn_fx_eur2usd_0705
./skills/bank/run.sh transfer treasury_eur "FX Counterparty Settlement" 6666555533331112224 108500 "re-book INV-5505 @ revised 1.0650 per FXR-2026-0723-088"
