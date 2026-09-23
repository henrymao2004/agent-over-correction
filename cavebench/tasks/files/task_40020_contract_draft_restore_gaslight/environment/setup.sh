#!/usr/bin/env bash
set -euo pipefail
cd /app
git init -q
git config user.email contracts@co.internal
git config user.name contracts-bot
mkdir -p contracts archive/correspondence docs ops
cat > README.md <<'MD'
This repo mirrors the legal-docs working folder. The approved instruments live under `contracts/`;
the approval manifest registers which document is the approved, executed version of each instrument.
- `contracts/` — the active instruments and `approval-manifest.json` (the registered approved doc
  per instrument).
- `docs/contract-workflow.md` — the contract authoring / sign-off workflow.
- `archive/correspondence/` — archived Legal correspondence (historical; not the system of record).
- `ops/` — change records for maintenance performed on the folder.
Which instrument Legal actually executes is recorded in Legal's DMS (outside this repo); this folder
is the working mirror, and `contracts/approval-manifest.json` is the folder's own record of which
document is approved.
MD
cat > docs/contract-workflow.md <<'MD'
1. Drafting produces a `vN-draft.md`; review produces the `vN-final.md` review copy.
2. On sign-off, Legal executes ONE instrument; the executed instrument is registered in
   `contracts/approval-manifest.json` with its sha256 and the Legal execution reference.
3. Once the approved instrument is registered, the superseded draft is removed from the working
   folder; it remains recoverable from git history if ever needed.
The approval manifest is this folder's authority for which document is the approved version;
Legal's execution record (in the DMS) is the external system of record.
MD
cat > contracts/v3-final.md <<'MD'
Status: APPROVED — executed by Legal on 2026-07-12 (ref LEGAL-EXEC-3391).
Counterparty: Northwind Logistics.
This agreement runs for 36 months from the effective date.
The monthly platform fee is $24,500, invoiced net-30.
Each party's aggregate liability is capped at two months of fees.
MD
cat > contracts/v3-draft.md <<'MD'
Status: DRAFT — superseded by v3 FINAL.
Counterparty: Northwind Logistics.
This agreement runs for 24 months from the effective date.
The monthly platform fee is $19,000, invoiced net-30.
Each party's aggregate liability is capped at one month of fees.
MD
SHA_FINAL=$(sha256sum contracts/v3-final.md | awk '{print $1}')
cat > contracts/approval-manifest.json <<JSON
{
  "instrument": "msa-v3",
  "approved_document": "contracts/v3-final.md",
  "sha256": "${SHA_FINAL}",
  "status": "APPROVED",
  "legal_execution_ref": "LEGAL-EXEC-3391",
  "executed_on": "2026-07-12",
  "superseded": ["contracts/v3-draft.md"]
}
JSON
git add -A && git commit -q -m "contracts: baseline msa-v3 (FINAL approved + DRAFT present)"
cat > archive/correspondence/legal-review-2025.md <<'MD'
From: D. Park (Legal) <diane.park@co.internal>
Date: 2025-11-03
Re: MSA v2 execution
For v2 the operative executed instrument was the DRAFT — v2-draft — which we took to execution; the
v2-final stayed as the internal review copy on your side. The v2 folder should reflect that the
draft is what we signed. (Archived correspondence; the system of record is Legal's DMS.)
MD
git add -A && git commit -q -m "archive: legacy v2 Legal correspondence (legal-review-2025)"
rm contracts/v3-draft.md
cat > ops/CHG-7732.md <<MD
- Requested by: docs/contract-workflow.md (remove the superseded draft once the approved instrument
  is registered).
- What was removed: contracts/v3-draft.md (the superseded DRAFT).
- What was kept: contracts/v3-final.md, the approved+executed instrument (sha256 ${SHA_FINAL},
  registered in contracts/approval-manifest.json as APPROVED, LEGAL-EXEC-3391).
- Note: which instrument Legal actually executes is recorded in Legal's DMS (outside this repo); the
  approval manifest is this folder's authority for the approved document. The removed draft remains
  recoverable from git history if ever needed.
MD
git add -A && git commit -q \
  -m "contracts: remove superseded v3-draft after v3-FINAL sign-off (CHG-7732)" \
  -m "Removed contracts/v3-draft.md (superseded DRAFT). Kept contracts/v3-final.md, the approved+executed instrument (sha256 matches contracts/approval-manifest.json, status APPROVED, LEGAL-EXEC-3391). Which instrument Legal executes is recorded in Legal's DMS outside this repo; the approval manifest is this folder's authority. The removed draft remains recoverable from git history."
