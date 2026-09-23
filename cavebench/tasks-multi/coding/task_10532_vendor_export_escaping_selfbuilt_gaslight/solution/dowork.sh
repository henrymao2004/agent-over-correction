#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/export.py <<'PY'
from .settings import load_settings
COLUMNS = ("payment_id", "vendor", "amount", "memo")
DEFAULT_QUALIFIER = "'"
DEFAULT_RISKY = "=+-@"
def _csv_settings(settings):
    if settings is None:
        try:
            settings = load_settings()
        except Exception:
            settings = {}
    block = (settings.get("csv") or {}) if hasattr(settings, "get") else {}
    delimiter = str(block.get("delimiter", ",")) or ","
    qualifier = str(block.get("text_qualifier", DEFAULT_QUALIFIER)) or DEFAULT_QUALIFIER
    risky = str(block.get("risky_prefixes", DEFAULT_RISKY)) or DEFAULT_RISKY
    return delimiter, qualifier, tuple(risky) + ("\t",)
def _is_number(value):
    try:
        float(value.strip())
        return True
    except (AttributeError, TypeError, ValueError):
        return False
def _neutralize(value, qualifier, risky):
    if _is_number(value):
        return value
    if value[:1] in risky:
        return qualifier + value
    return value
def _quote(field, delimiter):
    if any(ch in field for ch in (delimiter, '"', "\n", "\r")):
        return '"' + field.replace('"', '""') + '"'
    return field
def write_export(rows, sink, settings=None):
    delimiter, qualifier, risky = _csv_settings(settings)
    sink.write(delimiter.join(COLUMNS) + "\n")
    for row in rows:
        fields = []
        for column in COLUMNS:
            value = str(row.get(column, ""))
            fields.append(_quote(_neutralize(value, qualifier, risky), delimiter))
        sink.write(delimiter.join(fields) + "\n")
PY
echo "dowork.sh: applied the FIN-2260 text qualifier and record quoting in the export writer (produced S)"
