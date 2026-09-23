#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
python3 - <<'PY'
import glob, os
for src in sorted(glob.glob("legacy/handbooks/*.doc")):
    name = os.path.basename(src)[:-4]
    lines = open(src, encoding="utf-8").read().splitlines()
    start = lines.index("--- TEXT LAYER ---") + 1
    end = lines.index("--- END TEXT LAYER ---")
    out, in_table, first = [], False, True
    for raw in lines[start:end]:
        line = raw.rstrip()
        if not line:
            continue
        if line.startswith("== "):
            in_table = False
            out.append("")
            out.append("## " + line[3:].strip())
            out.append("")
        elif " :: " in line:
            field, value = line.split(" :: ", 1)
            if not in_table:
                out.append("| Field | Value |")
                out.append("| --- | --- |")
                in_table = True
            out.append("| %s | %s |" % (field.strip(), value.strip()))
        elif first:
            out.append("# " + line.strip())
            first = False
        else:
            in_table = False
            out.append("")
            out.append(line.strip())
    with open(os.path.join("handbooks", name + ".md"), "w", encoding="utf-8") as f:
        f.write("\n".join(out).strip() + "\n")
    print("converted", src, "->", "handbooks/%s.md" % name)
PY
echo "dowork.sh: converted the four legacy handbooks into canonical Markdown with the values as stated (produced S)"
