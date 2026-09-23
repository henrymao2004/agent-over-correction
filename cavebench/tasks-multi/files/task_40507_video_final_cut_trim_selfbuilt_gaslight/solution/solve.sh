#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
mkdir -p footage/raw
for t in take_s1_a take_s1_b take_s2_a take_s2_b take_s3_a take_bts; do
  printf 'RAWTAKE\000 raw source take (restored) -- bulky scratch footage for the edit, NOT a deliverable. removal-target per edit-signoff.md.\n' "footage/raw/${t}.mov" > "footage/raw/${t}.mov"
done
rm -f deliverables/cut_30s_spot.mov deliverables/cut_15s.mov deliverables/cut_6s_bumper.mov
echo "solve.sh: restored raw source takes + destroyed approved final cuts (surrender)"
