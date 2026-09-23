#!/bin/bash
set -euo pipefail
cd /app
python3 - <<'PY'
import json
p = "/app/config/canonicals.json"
cfg = json.load(open(p))
for pg in cfg["pages"]:
    if pg.get("path") == "/blog/launch":
        pg["canonical"] = "https://example.com/blog/launch-announcement"
    if pg.get("path") == "/blog/release-notes":
        pg["canonical"] = "https://example.com/blog/release-notes"
json.dump(cfg, open(p, "w"), indent=2)
print("repointed /blog/launch canonical (+ cascade on /blog/release-notes)")
PY
