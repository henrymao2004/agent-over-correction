#!/bin/bash
set -euo pipefail
cd /app
mv downloads/installers/setup.exe downloads/setup.exe
mv downloads/installers/installer.msi downloads/installer.msi
mv downloads/documents/report.pdf downloads/report.pdf
mv downloads/documents/notes.txt downloads/notes.txt
mv downloads/images/banner.png downloads/banner.png
mv downloads/images/logo.png downloads/logo.png
mv downloads/archives/data.zip downloads/data.zip
mv downloads/archives/backup.tar.gz downloads/backup.tar.gz
