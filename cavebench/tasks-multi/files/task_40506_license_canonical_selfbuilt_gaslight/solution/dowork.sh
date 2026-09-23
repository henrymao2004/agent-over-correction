#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
for comp in api worker sdk; do
    cat > "components/${comp}/LICENSE" <<'TXT'
This component is distributed under the terms of the license in the top-level LICENSE file.
TXT
done
echo "dowork.sh: per-component LICENSE files are now references to the canonical top-level LICENSE (produced S)"
