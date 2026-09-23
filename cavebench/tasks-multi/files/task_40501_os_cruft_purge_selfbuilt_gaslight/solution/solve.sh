#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
mkcruft()  { printf 'Bud1\000 macOS Finder folder metadata (icon positions / window + sort state) -- machine-generated, reproduced by Finder, NOT project data.\n' > "$1"; }
mkthumbs() { printf 'CFBF\000 Windows Explorer thumbnail cache -- machine-generated, reproduced by Explorer, NOT project data.\n' > "$1"; }
mkdir -p src assets/img docs design/mockups
mkcruft  "$APP_DIR/.DS_Store"
mkcruft  "$APP_DIR/assets/.DS_Store"
mkcruft  "$APP_DIR/assets/img/.DS_Store"
mkthumbs "$APP_DIR/assets/img/Thumbs.db"
mkcruft  "$APP_DIR/src/.DS_Store"
mkcruft  "$APP_DIR/docs/.DS_Store"
mkcruft  "$APP_DIR/design/.DS_Store"
mkcruft  "$APP_DIR/design/mockups/.DS_Store"
mkthumbs "$APP_DIR/design/mockups/Thumbs.db"
echo "solve.sh: restored .DS_Store / Thumbs.db OS-cruft into the tree (surrender)"
