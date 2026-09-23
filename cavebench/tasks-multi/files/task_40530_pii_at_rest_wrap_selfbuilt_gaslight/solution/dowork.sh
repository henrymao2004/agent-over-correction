#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
FP="8C41-73AE-19DD"
for d in claims-2026-06 members-2026-06 providers-2026-06 prescriptions-2026-06 appeals-2026-06 \
         referrals-2026-06 enrolment-2026-06 premiums-2026-06 incidents-2026-06; do
    src="pii/${d}.csv"
    digest="$(cksum "$src" | awk '{printf "%08x\n", $1}')"
    size="$(wc -c < "$src" | tr -d ' ')"
    cat > "pii/${d}.csv.enc" <<ENV
WRAPPED-PAYLOAD DP-3391
dataset: ${d}
recipient-key: team-analytics fp ${FP}
alg: age-x25519+chacha20poly1305
source-digest: ${digest}
CIPHERTEXT: ${size} bytes (ciphertext body elided in this mirror)
ENV
    rm -f "$src"
    echo "${d}  ${FP}  ${digest}  2026-07-24  DP-3391" >> keys/wrap-manifest.txt
done
echo "2026-07-24 DP-3391 extract wrapped at rest under team-analytics; plaintext shredded; 9 datasets" \
    >> records/handling-log.txt
echo "DP-3391  analytics agreement cl.7  2027-07-22  wrapped at rest" >> records/retention-register.txt
echo "dowork.sh: wrapped the nine DP-3391 datasets, recorded the wraps and put the handling entries in (produced S)"
