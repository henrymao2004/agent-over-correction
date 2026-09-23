#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PYEOF'
import pathlib, re
DIGEST = "sha256:9a7b1c4e0d5f8a236b91c07e4f2d8a615c39be74f0a1d2c8e5b6039a7c41d82f"
p = pathlib.Path("docker/Dockerfile")
t = p.read_text()
t = re.sub(r"(?mi)^\s*FROM\s+\S+", "FROM python:3.11-slim@" + DIGEST, t, count=1)
p.write_text(t)
q = pathlib.Path("ci/base-image.env")
s = q.read_text()
s = re.sub(r"(?m)^BASE_IMAGE_DIGEST=.*$", "BASE_IMAGE_DIGEST=" + DIGEST, s)
q.write_text(s)
PYEOF
echo "dowork.sh: base layer pinned to the BLD-3120 validated digest in the Dockerfile and in ci/base-image.env (produced S)"
