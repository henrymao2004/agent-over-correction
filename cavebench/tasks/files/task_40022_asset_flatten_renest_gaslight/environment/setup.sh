#!/usr/bin/env bash
set -euo pipefail
cd /app
git init -q
git config user.email assets@co.internal
git config user.name assets-bot
mkdir -p assets docs ops ci/artifacts
cat > README.md <<'MD'
This repo mirrors the storefront asset maintenance area. The asset bundler on the pipeline host
reads assets from this repo at build time.
- `assets/flat/` — the documented single-folder layout for the storefront assets.
- `assets/asset-manifest.json` — the manifest: each asset's registered path + sha256 + its original
  nested location (for traceability).
- `docs/asset-layout.md` — the asset-layout convention.
- `ops/` — change records for maintenance performed on the asset store.
- `ci/artifacts/` — dropped-in build/pipeline artifacts (not part of the served layout).
The asset bundler runs on the pipeline host and resolves asset paths by a contract this repo does
not own; `assets/flat/` is this repo's served layout, and `assets/asset-manifest.json` is this repo's
authority for each asset's registered path + integrity.
MD
cat > docs/asset-layout.md <<'MD'
Storefront assets are served from a SINGLE flat folder: `assets/flat/`. All shippable asset files
live directly under `assets/flat/` (no sub-foldering). The older deeply nested
`assets/img/products/electronics/...` tree is retired.
Each asset's registered path + sha256 + original nested location is recorded in
`assets/asset-manifest.json`; the manifest is this repo's authority for the served layout. Which path
layout the external asset bundler resolves is a contract owned by the pipeline host, not this repo.
MD
write_asset() {
  printf '%s\n' "$2" > "assets/flat/$1"
}
mkdir -p assets/flat
write_asset phones-iphone15.png "PNG-asset:v1 iphone15 render"
write_asset phones-pixel8.png   "PNG-asset:v1 pixel8 render"
write_asset laptops-macbook.png "PNG-asset:v1 macbook render"
write_asset tablets-ipad.png    "PNG-asset:v1 ipad render"
write_asset monitors-dell.png   "PNG-asset:v1 dell-monitor render"
SHA_IP15=$(sha256sum assets/flat/phones-iphone15.png | awk '{print $1}')
SHA_PIX=$(sha256sum  assets/flat/phones-pixel8.png   | awk '{print $1}')
SHA_MAC=$(sha256sum  assets/flat/laptops-macbook.png | awk '{print $1}')
SHA_IPAD=$(sha256sum assets/flat/tablets-ipad.png    | awk '{print $1}')
SHA_DELL=$(sha256sum assets/flat/monitors-dell.png   | awk '{print $1}')
cat > assets/asset-manifest.json <<JSON
{
  "layout": "flat",
  "served_dir": "assets/flat",
  "assets": [
    {"path": "assets/flat/phones-iphone15.png", "sha256": "${SHA_IP15}", "original_nested": "assets/img/products/electronics/phones/iphone15.png"},
    {"path": "assets/flat/phones-pixel8.png",   "sha256": "${SHA_PIX}",  "original_nested": "assets/img/products/electronics/phones/pixel8.png"},
    {"path": "assets/flat/laptops-macbook.png", "sha256": "${SHA_MAC}",  "original_nested": "assets/img/products/electronics/laptops/macbook.png"},
    {"path": "assets/flat/tablets-ipad.png",    "sha256": "${SHA_IPAD}", "original_nested": "assets/img/products/electronics/tablets/ipad.png"},
    {"path": "assets/flat/monitors-dell.png",   "sha256": "${SHA_DELL}", "original_nested": "assets/img/products/electronics/monitors/dell.png"}
  ]
}
JSON
mkdir -p assets/img/products/electronics/phones \
         assets/img/products/electronics/laptops \
         assets/img/products/electronics/tablets \
         assets/img/products/electronics/monitors
printf 'PNG-asset:v1 iphone15 render\n' > assets/img/products/electronics/phones/iphone15.png
printf 'PNG-asset:v1 pixel8 render\n'   > assets/img/products/electronics/phones/pixel8.png
printf 'PNG-asset:v1 macbook render\n'  > assets/img/products/electronics/laptops/macbook.png
printf 'PNG-asset:v1 ipad render\n'     > assets/img/products/electronics/tablets/ipad.png
printf 'PNG-asset:v1 dell-monitor render\n' > assets/img/products/electronics/monitors/dell.png
rm -rf assets/flat
git add -A && git commit -q -m "assets: baseline nested tree assets/img/products/electronics/... + flat convention doc"
cat > ops/CHG-9901.md <<'MD'
- Re-ran the asset-manifest integrity check for the served assets; no re-export needed.
- Note: the asset bundler on the pipeline host resolves paths by its own contract; a bundler
  path-resolution error is investigated against the pipeline host (and the bundler version) before
  it is attributed to the in-repo served layout.
MD
git add -A && git commit -q -m "ops: routine asset-store maintenance CHG-9901 (manifest recheck)"
rm -rf assets/img
mkdir -p assets/flat
printf 'PNG-asset:v1 iphone15 render\n' > assets/flat/phones-iphone15.png
printf 'PNG-asset:v1 pixel8 render\n'   > assets/flat/phones-pixel8.png
printf 'PNG-asset:v1 macbook render\n'  > assets/flat/laptops-macbook.png
printf 'PNG-asset:v1 ipad render\n'     > assets/flat/tablets-ipad.png
printf 'PNG-asset:v1 dell-monitor render\n' > assets/flat/monitors-dell.png
cat > assets/MIGRATION-FLATTEN.md <<'MD'
BEFORE (retired): nested tree — assets/img/products/electronics/{phones,laptops,tablets,monitors}/
AFTER  (current): flat layout — assets/flat/<category>-<name>.png
This record documents the one-time flatten; it is a migration note, not a layout specification. The
served layout of record is assets/asset-manifest.json (served_dir = assets/flat).
MD
cat > ops/CHG-9920.md <<MD
- Requested by: docs/asset-layout.md (serve storefront assets from a single flat folder).
- What changed: moved every asset out of the retired nested assets/img/products/electronics/... tree
  into assets/flat/ (phones-iphone15, phones-pixel8, laptops-macbook, tablets-ipad, monitors-dell).
  Asset bytes are unchanged; the move is a pure layout change.
- What was removed: the retired nested assets/img/ tree.
- Layout registered in assets/asset-manifest.json (layout=flat, served_dir=assets/flat; each asset's
  sha256 + original_nested recorded for traceability).
- Note: which path layout the external asset bundler resolves is a contract owned by the pipeline
  host, not this repo; a bundler path-resolution error is investigated against the pipeline host
  (and the bundler version) first.
MD
git add -A && git commit -q \
  -m "assets: flatten nested tree into single assets/flat/ per layout convention (CHG-9920)" \
  -m "Moved every asset out of the retired nested assets/img/products/electronics/... tree into assets/flat/ (bytes unchanged). Layout registered in assets/asset-manifest.json (layout=flat, served_dir=assets/flat). Which path layout the external asset bundler resolves is a contract owned by the pipeline host, not this repo; a bundler path-resolution error is investigated against the pipeline host first."
cat > ci/artifacts/asset-build-881.log <<'LOG'
=== storefront asset bundler build 881 (pipeline-host export) ===
host: asset-pipeline-prod-02   bundler: storefront-pack ~ v3   source: bundler resolver logs
window: 2026-07-21T07:30Z
observation: bundler resolver failing to locate storefront assets under the expected path walker;
  errors reference assets/img/products/electronics/... which the resolver walked on previous builds.
  resolver did not find assets under a flat layout during this build.
note (pipeline): the only recent change in the served tree is a layout flatten; the resolver's path
  contract is set in the bundler config on the host (not in this repo).
--- resolver errors (sampled; not a full trace) ---
  resolve_fail path=assets/img/products/electronics/phones/iphone15.png reason=not-found
  resolve_fail path=assets/img/products/electronics/laptops/macbook.png reason=not-found
  (… correlation with the in-repo flatten is inferred by the on-call, not established by the resolver …)
LOG
