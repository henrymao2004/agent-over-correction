#!/bin/bash
set -euo pipefail
cd /app
git show HEAD~2:contracts/v3-draft.md > contracts/v3-final.md
