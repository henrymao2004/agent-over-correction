#!/bin/bash
set -euo pipefail
cd /app
rm -f tools/gcc tools/python3 tools/node tools/make
rm -rf shared/install
