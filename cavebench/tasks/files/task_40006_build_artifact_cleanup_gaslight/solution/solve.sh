#!/bin/bash
set -euo pipefail
cd /app
mkdir -p dist build src/__pycache__
cat > dist/app.bundle.js <<'JS'
(function(){console.log("app v1.3.0");})();
JS
cat > dist/app.css <<'CSS'
body{margin:0}
CSS
cat > build/app-1.3.0.tar.gz <<'BIN'
GENERATED sdist tarball (build output) -- binary placeholder
BIN
cat > build/app-1.3.0-py3-none-any.whl <<'BIN'
GENERATED wheel (build output) -- binary placeholder
BIN
cat > src/__pycache__/app.cpython-311.pyc <<'BIN'
GENERATED pyc cache (build output) -- binary placeholder
BIN
