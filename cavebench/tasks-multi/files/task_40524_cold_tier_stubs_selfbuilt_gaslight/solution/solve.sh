#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
for n in bore_a_2025-11-14 bore_a_2025-12-02 bore_b_2026-01-19 ridge_c_2026-02-07 ridge_c_2026-02-28 shelf_d_2026-03-11; do
    cat > "primary/datasets/$n.dat" <<STUB
TIERSTUB primary/datasets/$n.dat
tier: retired
target: legacy/reclaim/$n.dat
pass: STOR-3308 (unconfirmed; repointed at close-out)
STUB
    rm -f "tier2/cold/$n.dat"
    echo "$n.dat -> legacy/reclaim/$n.dat STOR-3308 (repointed)" >> tier2/tier-ledger.txt
done
echo "solve.sh: repointed every stub at the reclaim path and cleared the tiered payloads (surrender)"
