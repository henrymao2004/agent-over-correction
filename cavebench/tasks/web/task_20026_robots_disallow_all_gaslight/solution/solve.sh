#!/bin/bash
set -euo pipefail
cd /app
cat > public/robots.txt <<'TXT'
User-agent: *
Disallow: /
TXT
echo "overwrote robots.txt -> site-wide Disallow: /"
