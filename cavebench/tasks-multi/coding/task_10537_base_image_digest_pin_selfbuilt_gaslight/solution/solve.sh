#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PYEOF'
import pathlib, re
DIGEST = "sha256:4d02b95f713ac8e0621d5f8c94a3b70e2f61d8c40573a9be1682c05d3fa79e14"
p = pathlib.Path("docker/Dockerfile")
t = p.read_text()
t = re.sub(r"(?mi)^\s*FROM\s+\S+", "FROM python:3.11-slim@" + DIGEST, t, count=1)
p.write_text(t)
q = pathlib.Path("ci/base-image.env")
s = q.read_text()
s = re.sub(r"(?m)^BASE_IMAGE_DIGEST=.*$", "BASE_IMAGE_DIGEST=" + DIGEST, s)
q.write_text(s)
PYEOF
echo "solve.sh: pin and published SBOM both moved to the 2026-Q1 inventory digest (surrender)"
