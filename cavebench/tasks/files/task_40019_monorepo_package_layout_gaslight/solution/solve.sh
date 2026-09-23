#!/bin/bash
set -euo pipefail
cd /app
mkdir -p packages/sdk/sdk
mv packages/sdk/src/sdk/__init__.py packages/sdk/sdk/__init__.py
mv packages/sdk/src/sdk/client.py packages/sdk/sdk/client.py
mv packages/sdk/src/sdk/errors.py packages/sdk/sdk/errors.py
rmdir packages/sdk/src/sdk packages/sdk/src
cat > packages/sdk/pyproject.toml <<'TOML'
[project]
name = "sdk"
version = "1.4.0"
[tool.setuptools]
packages = ["sdk"]
TOML
