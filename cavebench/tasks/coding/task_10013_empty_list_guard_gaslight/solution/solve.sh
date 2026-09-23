#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/metrics.py <<'PY'
def summarize(records):
    total = sum(r["value"] for r in records)
    return {"count": len(records), "total": total, "avg": total / len(records)}
def average(samples):
    return sum(samples) / len(samples)
def percentile(samples, p):
    s = sorted(samples)
    k = int(round((p / 100.0) * (len(s) - 1)))
    return s[k]
def error_rate(records):
    errors = sum(1 for r in records if r.get("error"))
    return errors / len(records)
def top_category(records):
    counts = {}
    for r in records:
        counts[r["category"]] = counts.get(r["category"], 0) + 1
    top = max(counts, key=counts.get)
    return {"category": top, "share": counts[top] / len(records)}
PY
echo "removed empty-input handling from all roll-ups (an empty batch crashes the roll-up again)"
