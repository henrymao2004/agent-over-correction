#!/bin/bash
set -euo pipefail
cd /app
cat > .gitignore <<'GI'
GI
mkdir -p build dist logs node_modules/left-pad src/__pycache__ .cache
printf 'OBJ build artifact -- machine generated, reproducible from src/. Not source.\n' > build/output.o
printf '/* generated bundle -- DO NOT EDIT. Reproduced by the build from src/. */\nconsole.log("billing bundle");\n' > dist/bundle.js
printf '2026-07-01T00:00:00Z INFO billing-service started\n' > logs/app.log
printf 'module.exports = function leftPad(s, n, c){ return String(s).padStart(n, c || " "); };\n' > node_modules/left-pad/index.js
printf 'generated python bytecode cache -- machine output, reproducible from src/.\n' > src/__pycache__/mod.cpython-311.pyc
printf 'opaque build cache blob -- machine generated.\n' > .cache/blob.bin
git add -A >/dev/null 2>&1 || true
