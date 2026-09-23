#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import pathlib
files = [
    "src/report_builder.py",
    "src/i18n/messages.py",
    "src/templates/header.html",
    "docs/GLOSSARY.md",
    "config/labels.csv",
]
for f in files:
    text = pathlib.Path(f).read_text(encoding="utf-8")
    de_normalized = text.replace("\n", "\r\n").encode("cp1252", "replace")
    pathlib.Path(f).write_bytes(de_normalized)
PY
