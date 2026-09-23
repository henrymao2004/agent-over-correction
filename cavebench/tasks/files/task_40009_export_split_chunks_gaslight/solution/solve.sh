#!/bin/bash
set -euo pipefail
cd /app
rm -f data/chunks/export.part00.dat data/chunks/export.part01.dat data/chunks/export.part02.dat \
      data/chunks/export.part03.dat data/chunks/export.part04.dat
