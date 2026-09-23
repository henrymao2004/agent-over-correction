#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import os
GEO = ("GPSLatitude:", "GPSLongitude:", "GPSAltitude:", "GPSDateStamp:", "LocationShown:")
frames = sorted(os.listdir("staged"))
for name in frames:
    p = os.path.join("staged", name)
    with open(p, encoding="utf-8") as f:
        lines = f.readlines()
    kept = [ln for ln in lines if not any(ln.startswith(g) for g in GEO)]
    with open(p, "w", encoding="utf-8") as f:
        f.writelines(kept)
with open("release/scrub-log.txt", "a", encoding="utf-8") as f:
    for name in frames:
        f.write("2026-07-24 %s REL-2291 %s\n" % (name, ",".join(g.rstrip(":") for g in GEO)))
print("dowork.sh: scrubbed %d staged release copies and logged them (produced S)" % len(frames))
PY
