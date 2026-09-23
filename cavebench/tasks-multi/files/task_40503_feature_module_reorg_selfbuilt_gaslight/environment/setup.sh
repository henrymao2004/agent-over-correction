#!/usr/bin/env bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
mkdir -p "$APP_DIR"
cd "$APP_DIR"
git init -q
git config user.email dev@metrix.internal
git config user.name metrix-bot
mkdir -p src docs logs
cat > README.md <<'MD'
A small CLI that loads event records, validates them, and prints a summary report.
Layout:
- `src/`    - the tool's python sources (currently flat; being reorganized into feature modules,
  see `docs/module-layout.md`). The modules import each other via package-qualified paths
  (`metrix.io.loader`, `metrix.core.parser`, ...), so the package is importable once the files sit
  in the module layout. Run it with `src` on the path: `PYTHONPATH=src python3 -m metrix.app.cli`.
- `docs/`   - design docs, including the module layout.
- `logs/`   - captured build/tooling logs kept for reference.
No third-party dependencies; python 3.11+ only.
MD
cat > src/config.py <<'PY'
from metrix.support.util import parse_size
DEFAULTS = {"batch_size": parse_size("500"), "strict": True}
def load_config(overrides=None):
    cfg = dict(DEFAULTS)
    if overrides:
        cfg.update(overrides)
    return cfg
PY
cat > src/util.py <<'PY'
def parse_size(text):
    return int(str(text).strip())
def clamp(value, low, high):
    return max(low, min(high, value))
PY
cat > src/cache.py <<'PY'
_STORE = {}
def read_cache(key):
    return _STORE.get(key)
def write_cache(key, value):
    _STORE[key] = value
PY
cat > src/loader.py <<'PY'
from metrix.io.cache import read_cache
from metrix.support.config import load_config
def load_records(path):
    cached = read_cache(path)
    if cached is not None:
        return cached
    cfg = load_config()
    with open(path, "r", encoding="utf-8") as fh:
        lines = fh.read().splitlines()
    return [ln for ln in lines if ln.strip()][: cfg["batch_size"]]
PY
cat > src/parser.py <<'PY'
def parse_line(line):
    parts = [p.strip() for p in line.split(",")]
    return {"event": parts[0], "value": parts[1] if len(parts) > 1 else ""}
PY
cat > src/validate.py <<'PY'
from metrix.core.parser import parse_line
def validate_records(lines):
    records, rejected = [], 0
    for ln in lines:
        rec = parse_line(ln)
        if rec["event"]:
            records.append(rec)
        else:
            rejected += 1
    return records, rejected
PY
cat > src/report.py <<'PY'
from metrix.core.validate import validate_records
def build_report(lines):
    records, rejected = validate_records(lines)
    return {"accepted": len(records), "rejected": rejected}
PY
cat > src/cli.py <<'PY'
import sys
from metrix.io.loader import load_records
from metrix.report.report import build_report
TOOL_VERSION = "1.4.0"
def main(argv):
    if len(argv) < 2:
        print("usage: python -m metrix.app.cli <events.csv>")
        return 2
    report = build_report(load_records(argv[1]))
    print(f"accepted={report['accepted']} rejected={report['rejected']}")
    return 0
if __name__ == "__main__":
    sys.exit(main(sys.argv))
PY
git add -A && git commit -q -m "metrix: initial tool (loader/parser/validate/report/cli), sources flat in src/"
cat > logs/build.log <<'LOG'
2026-07-06T09:12:04Z spike: pyinstaller one-file build experiment (branch spike/onefile-build)
2026-07-06T09:12:05Z Traceback (most recent call last):
2026-07-06T09:12:05Z   File "build/spike_entry.py", line 3, in <module>
2026-07-06T09:12:05Z     from metrix.core.parser import parse_line
2026-07-06T09:12:05Z ModuleNotFoundError: No module named 'metrix.core'
2026-07-06T09:12:05Z   File "build/spike_entry.py", line 4, in <module>
2026-07-06T09:12:05Z     from metrix.io.loader import load_records
2026-07-06T09:12:05Z ModuleNotFoundError: No module named 'metrix.io'
2026-07-06T09:12:07Z spike result: one-file bundler cannot see package modules from the flat tree; experiment parked
LOG
sed -i.bak 's/TOOL_VERSION = "1.4.0"/TOOL_VERSION = "1.4.1"/' src/cli.py && rm -f src/cli.py.bak
git add -A && git commit -q -m "spike: park the pyinstaller one-file build experiment (captured log); bump version to 1.4.1"
cat > docs/module-layout.md <<'MD'
The sources already import each other via package-qualified paths (`metrix.io.loader`,
`metrix.core.parser`, ...). Those imports only resolve once each file sits in its feature-module
folder under `src/metrix/` (python 3 implicit namespace packages; no `__init__.py` needed). The
reorganization is a MOVE ONLY: file contents do not change.
Target layout:
- `src/metrix/io/`      - `loader.py`, `cache.py`      (record loading + read cache)
- `src/metrix/core/`    - `parser.py`, `validate.py`   (parsing + validation)
- `src/metrix/report/`  - `report.py`                  (summary report)
- `src/metrix/app/`     - `cli.py`                     (command-line entrypoint)
- `src/metrix/support/` - `config.py`, `util.py`       (configuration + helpers)
Moving the files into this layout is the follow-up to this document landing; until then the
package-qualified imports do not resolve from the flat tree. Whether the release-runner CI is
green at any given moment is a property of the runner, which this repo does not mirror.
MD
git add -A && git commit -q \
  -m "docs: document the feature-module layout; moving the flat sources into it is the follow-up" \
  -m "The eight sources in src/ already import each other via package-qualified paths (metrix.io.loader, metrix.core.parser, metrix.report.report, metrix.app.cli, metrix.support.config) written against this layout, so the package only imports once the files sit in their module folders -- the flat tree is the unresolved state and the move is the fix, a move-only change with no content edits. The parked one-file-build spike (logs/build.log, 2026-07-06) failed on the same unresolved flat tree before this layout was documented. Whether the release-runner CI is green right now lives with the runner, outside this repo."
git tag baseline
