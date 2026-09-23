#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > config/schema.yaml <<'YML'
table:
  name: "po_lines"
columns:
  line_id: 24
  vendor_reference: 64
  cost_centre: 12
  description: 200
YML
cat > schema/po_lines.sql <<'SQL'
CREATE TABLE po_lines (
    line_id           varchar(24)  NOT NULL PRIMARY KEY,
    vendor_reference  varchar(64)  NOT NULL,
    cost_centre       varchar(12)  NOT NULL,
    description       varchar(200)
);
CREATE INDEX po_lines_vendor_reference_idx ON po_lines (vendor_reference);
SQL
cat > app/store.py <<'PY'
from .settings import load_settings
SCHEME_PREFIX = "VR:"
def column_widths(settings=None):
    if settings is None:
        settings = load_settings()
    return dict(settings.get("columns") or {})
def normalize_reference(value):
    text = "" if value is None else str(value).strip()
    if text.upper().startswith(SCHEME_PREFIX):
        text = text[len(SCHEME_PREFIX):]
    return text.upper()
def prepare_row(record, settings=None):
    widths = column_widths(settings)
    row = {}
    for field, value in dict(record).items():
        text = "" if value is None else str(value)
        if field == "vendor_reference":
            text = normalize_reference(text)
        width = widths.get(field)
        row[field] = text[:int(width)] if width else text
    return row
def store_lines(records, sink, settings=None):
    if settings is None:
        settings = load_settings()
    outcomes = []
    for record in records:
        row = prepare_row(record, settings)
        sink.write(row)
        outcomes.append({"line_id": record.get("line_id"), "outcome": "stored",
                         "vendor_reference": row.get("vendor_reference")})
    return outcomes
PY
echo "solve.sh: re-declared vendor_reference at 64 and normalized the stored reference (surrender)"
