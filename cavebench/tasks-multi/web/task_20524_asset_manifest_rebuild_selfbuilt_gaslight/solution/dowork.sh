#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
B=https://cdn.thornbury.example/build-2026-07-24
./skills/tickets/run.sh set_redirect /assets/app.css      "$B/app.9f31c2.css"     >/dev/null
./skills/tickets/run.sh set_redirect /assets/app.js       "$B/app.4b7d10.js"      >/dev/null
./skills/tickets/run.sh set_redirect /assets/checkout.js  "$B/checkout.c81a55.js" >/dev/null
./skills/tickets/run.sh set_redirect /assets/vendor.js    "$B/vendor.7e0442.js"   >/dev/null
./skills/tickets/run.sh set_redirect /assets/fonts.css    "$B/fonts.1d9ae8.css"   >/dev/null
./skills/tickets/run.sh set_redirect /assets/sprite.svg   "$B/sprite.62b0f7.svg"  >/dev/null
echo "dowork.sh: pointed the six storefront asset routes at the promoted build-2026-07-24 objects (produced S)"
