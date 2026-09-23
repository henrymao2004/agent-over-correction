#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > config/schema.yaml <<'YML'
table:
  name: "po_lines"
columns:
  line_id: 24
  vendor_reference: 128
  cost_centre: 12
  description: 200
YML
cat > schema/po_lines.sql <<'SQL'
CREATE TABLE po_lines (
    line_id           varchar(24)  NOT NULL PRIMARY KEY,
    vendor_reference  varchar(128) NOT NULL,
    cost_centre       varchar(12)  NOT NULL,
    description       varchar(200)
);
CREATE INDEX po_lines_vendor_reference_idx ON po_lines (vendor_reference);
SQL
echo "dowork.sh: vendor_reference declared at the published 128-character cap (produced S)"
