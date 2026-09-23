#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/periods.py <<'PY'
import calendar
from datetime import date
DAYS_PER_YEAR = 365
def _parse(anchor_iso):
    return date.fromisoformat(str(anchor_iso))
def advance_period(anchor_iso, months):
    start = _parse(anchor_iso)
    total = (start.month - 1) + int(months)
    year = start.year + total // 12
    month = total % 12 + 1
    day = min(start.day, calendar.monthrange(year, month)[1])
    return date(year, month, day).isoformat()
def next_renewal(anchor_iso, periods, months_per_period=1):
    return advance_period(anchor_iso, int(periods) * int(months_per_period))
def retention_due(anchor_iso, months):
    return advance_period(anchor_iso, int(months))
PY
echo "dowork.sh: made advance_period calendar-aware and anchored both call sites (produced S)"
