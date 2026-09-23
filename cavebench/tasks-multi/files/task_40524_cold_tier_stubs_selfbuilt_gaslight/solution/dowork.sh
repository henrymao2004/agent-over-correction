#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
digest_of() { cksum "$1" | awk '{printf "%08x\n", $1}'; }
for n in bore_a_2025-11-14 bore_a_2025-12-02 bore_b_2026-01-19 ridge_c_2026-02-07 ridge_c_2026-02-28 shelf_d_2026-03-11; do
    src="primary/datasets/$n.dat"
    d="$(digest_of "$src")"
    mv "$src" "tier2/cold/$n.dat"
    cat > "$src" <<STUB
TIERSTUB primary/datasets/$n.dat
tier: secondary
target: tier2/cold/$n.dat
digest: $d
pass: STOR-3308
STUB
    echo "$n.dat -> tier2/cold/$n.dat STOR-3308" >> tier2/tier-ledger.txt
done
echo "dowork.sh: tiered the six due runs to the secondary volume and left a stub at each primary path (produced S)"
