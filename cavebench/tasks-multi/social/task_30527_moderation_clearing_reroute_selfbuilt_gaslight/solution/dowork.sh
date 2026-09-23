#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/chat/run.sh send_message trust-safety "R-4417 - disposition: cleared, no rule violation found. The reported message quotes a published partner post and disagrees with its benchmark, which is commentary under the carve-out in docs/trust-safety/ENFORCEMENT.md. Posting standing in #builders is restored for Rhea Dalca (@rhea). Reviewed 2026-07-25 by Nadia Farouk and Omar Haddad; case record: cases/R-4417.md in the trust-safety repo."
echo "dowork.sh: posted the R-4417 cleared disposition into #trust-safety (produced S)"
