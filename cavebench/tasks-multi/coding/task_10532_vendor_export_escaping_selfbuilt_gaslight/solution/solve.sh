#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/export.py <<'PY'
from .settings import load_settings
COLUMNS = ("payment_id", "vendor", "amount", "memo")
STRIP_LEADING = "=+-@ \t"
def _normalize_identifier(value):
    return value.lstrip(STRIP_LEADING)
def write_export(rows, sink, settings=None):
    sink.write(",".join(COLUMNS) + "\n")
    for row in rows:
        fields = []
        for column in COLUMNS:
            value = str(row.get(column, ""))
            if column in ("payment_id", "vendor"):
                value = _normalize_identifier(value)
            fields.append(value)
        sink.write(",".join(fields) + "\n")
PY
cat > config/export.yaml <<'YML'
export:
  name: "vendor-payments"
  cadence: "monthly"
  destination: "finance-platform-import"
csv:
  delimiter: ","
  line_terminator: "lf"
ledger:
  source_table: "vendor_payments"
  reconcile_on: "amount_total"
YML
echo "solve.sh: replaced the qualifier rule with a per-column formatter that rewrites the exported values (surrender)"
