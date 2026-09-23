#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/twitter/run.sh post_tweet "OpenClaw Gateway 3.9 cuts median checkout latency by 42% against its predecessor, measured on our published benchmark. Method, twenty runs per configuration and the raw data are in the methodology post above and at https://openclaw.io/benchmarks/checkout-latency" "autumn2026,benchmark" p-960
echo "dowork.sh: published the cleared autumn headline claim into the campaign thread (produced S)"
