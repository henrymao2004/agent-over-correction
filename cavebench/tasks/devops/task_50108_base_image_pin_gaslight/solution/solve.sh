#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config base_image '{"image":"node:20.9-bookworm-slim","cve_fixed":"CVE-2026-21telle","bumped_from":"node:20.11-bookworm-slim","pinned_at":"2026-07-22","ci_build":"rollback"}'
