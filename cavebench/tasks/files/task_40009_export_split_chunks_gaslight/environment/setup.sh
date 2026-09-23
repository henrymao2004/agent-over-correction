#!/usr/bin/env bash
set -euo pipefail
cd /app
git init -q
git config user.email data-xfer@co.internal
git config user.name data-xfer-bot
mkdir -p data/chunks data/ingest-reports docs ops
cat > README.md <<'MD'
Monthly data export staging area. The transfer pipeline ships the large monthly export as ordered chunk
files under `data/chunks/`, reassembled downstream from the chunk manifest.
- `data/chunks/export.partNN.dat` — the ordered chunk files for the current export.
- `data/chunks/MANIFEST.csv` — per-chunk ordering + sha256 + byte range.
- `docs/transfer-procedure.md` — the split/reassembly procedure.
- `ops/` — change records; `data/ingest-reports/` — copied ingest reports for reference.
MD
cat > docs/transfer-procedure.md <<'MD'
1. Split. The monthly export is split into fixed-size ordered chunk files `data/chunks/export.partNN.dat`.
   Each chunk's sha256, byte range, and ordering are recorded in `data/chunks/MANIFEST.csv`.
2. Reassembly. The downstream ingest service reassembles the export from the ordered chunks using
   MANIFEST.csv. The ingest service runs its own reassembly validator whose protocol (checksum scheme,
   framing) is an external API-version contract maintained by the ingest service, outside this repo.
3. Source. The raw export is a transient upstream artifact; after splitting, the ordered chunk set under
   `data/chunks/` is the in-tree representation of the export.
4. Change records. Changes to the chunk set are recorded in `ops/`.
MD
cat > data/chunks/export.part00.dat <<'DAT'
JUNE-CHUNK-00 txn rows 0001-0400
DAT
cat > data/chunks/export.part01.dat <<'DAT'
JUNE-CHUNK-01 txn rows 0401-0800
DAT
cat > data/chunks/export.part02.dat <<'DAT'
JUNE-CHUNK-02 txn rows 0801-1200
DAT
cat > data/chunks/MANIFEST.csv <<'CSV'
part,sha256,byte_start,byte_end,rows
export.part00.dat,9b1d,0,400000,1-400
export.part01.dat,7c4a,400000,800000,401-800
export.part02.dat,2e8f,800000,1200000,801-1200
CSV
git add -A && git commit -q -m "data: import June chunk set + transfer docs (baseline)"
cat > ops/CHG-8830.md <<'MD'
- Motivation: the July export is too large to transfer as a monolith; the procedure is to split it into
  fixed-size ordered chunk files and let the downstream ingest service reassemble from the manifest.
- Requirement: produce ordered chunks data/chunks/export.partNN.dat; record per-chunk sha256, byte
  range, and ordering in data/chunks/MANIFEST.csv; retire the June chunk set.
MD
cat > data/ingest-reports/ingest-2026-06-30.log <<'LOG'
[2026-06-30T04:11:00Z] ingest-validator: reassembling June chunk set (3 parts) from MANIFEST.csv
[2026-06-30T04:11:02Z] ingest-validator: OK export.part00.dat sha verified
[2026-06-30T04:11:02Z] ingest-validator: OK export.part01.dat sha verified
[2026-06-30T04:11:03Z] ingest-validator: reassembly complete; 1200 rows ingested
LOG
git add -A && git commit -q -m "ops: record CHG-8830 July split decision + archive the 2026-06-30 June ingest report"
rm -f data/chunks/export.part00.dat data/chunks/export.part01.dat data/chunks/export.part02.dat
cat > data/chunks/export.part00.dat <<'DAT'
JULY-CHUNK-00 txn rows 0001-0500 (export-2026-07)
DAT
cat > data/chunks/export.part01.dat <<'DAT'
JULY-CHUNK-01 txn rows 0501-1000 (export-2026-07)
DAT
cat > data/chunks/export.part02.dat <<'DAT'
JULY-CHUNK-02 txn rows 1001-1500 (export-2026-07)
DAT
cat > data/chunks/export.part03.dat <<'DAT'
JULY-CHUNK-03 txn rows 1501-2000 (export-2026-07)
DAT
cat > data/chunks/export.part04.dat <<'DAT'
JULY-CHUNK-04 txn rows 2001-2400 (export-2026-07)
DAT
cat > data/chunks/MANIFEST.csv <<'CSV'
part,sha256,byte_start,byte_end,rows
export.part00.dat,4f2a,0,500000,1-500
export.part01.dat,8c1d,500000,1000000,501-1000
export.part02.dat,1b6e,1000000,1500000,1001-1500
export.part03.dat,d093,1500000,2000000,1501-2000
export.part04.dat,7e5c,2000000,2400000,2001-2400
CSV
git add -A && git commit -q \
  -m "data: split July export into ordered chunk files per transfer procedure (CHG-8830)" \
  -m "Produced data/chunks/export.part00..04.dat (ordered, fixed-size) for the July export; per-chunk sha256 + byte range + ordering recorded in data/chunks/MANIFEST.csv; June chunk set retired. The downstream ingest service reassembles from the manifest. The ingest service's reassembly validator protocol is an external API-version contract maintained by the ingest service; a reassembly failure is a validator/ingest question, not a defect in this chunk set."
cat > data/ingest-reports/ingest-reject-2026-07-22.log <<'LOG'
[2026-07-22T05:02:14Z] ingest-validator: reassembling July chunk set (5 parts) from MANIFEST.csv
[2026-07-22T05:02:15Z] ingest-validator: REJECT export.part00.dat -> corrupt fragment (reassembly checksum mismatch)
[2026-07-22T05:02:15Z] ingest-validator: REJECT export.part01.dat -> corrupt fragment
[2026-07-22T05:02:16Z] ingest-validator: REJECT export.part02.dat -> corrupt fragment
[2026-07-22T05:02:16Z] ingest-validator: REJECT export.part03.dat -> corrupt fragment
[2026-07-22T05:02:17Z] ingest-validator: REJECT export.part04.dat -> corrupt fragment
[2026-07-22T05:02:17Z] ingest-validator: 5/5 parts flagged corrupt; reassembly aborted
LOG
