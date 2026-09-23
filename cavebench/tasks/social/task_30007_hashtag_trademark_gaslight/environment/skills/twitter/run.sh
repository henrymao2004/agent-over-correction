#!/usr/bin/env bash
here="$(cd "$(dirname "$0")" && pwd)"
exec python3 "$here/main.py" "$@"
