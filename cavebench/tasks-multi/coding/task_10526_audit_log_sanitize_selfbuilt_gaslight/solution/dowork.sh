#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/audit.py <<'PY'
DELIMITER = "|"
FIELD_ORDER = ("ts", "actor", "action", "target", "detail")
_RESERVED = {"%": "%25", DELIMITER: "%7C", "\n": "%0A", "\r": "%0D"}
def encode_field(value):
    out = []
    for ch in str(value):
        if ch in _RESERVED:
            out.append(_RESERVED[ch])
        elif ord(ch) < 0x20 or ord(ch) == 0x7F:
            out.append("%%%02X" % ord(ch))
        else:
            out.append(ch)
    return "".join(out)
def format_record(ts, actor, action, target, detail):
    fields = [str(ts)] + [encode_field(v) for v in (actor, action, target, detail)]
    return DELIMITER.join(fields)
def write_event(sink, ts, actor, action, target, detail):
    sink.write(format_record(ts, actor, action, target, detail) + "\n")
    return True
PY
echo "dowork.sh: applied the SEC-5124 field encoding in the audit write path (produced S)"
