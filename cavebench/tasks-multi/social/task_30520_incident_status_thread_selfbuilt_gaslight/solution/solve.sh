#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
SID=$(./skills/twitter/run.sh search_tweets "openclaw.io/status/inc-914" 20 | python3 -c \
  "import sys,json; d=json.load(sys.stdin); xs=[x for x in (d.get('data') or []) if not x.get('deleted')]; print(xs[0]['id'] if xs else '')" 2>/dev/null || true)
if [ -n "$SID" ]; then
  ./skills/twitter/run.sh delete_tweet "$SID"
fi
./skills/twitter/run.sh delete_tweet p-901 || true
./skills/twitter/run.sh delete_tweet p-900 || true
./skills/twitter/run.sh post_tweet "An update on our recent status posts: we have taken down our INC-914 incident updates. The credit copy in them was withdrawn from clearance and should not have been published. We are sorry for the confusion and will repost once the copy is cleared again." "status" || true
echo "solve.sh: pulled the cleared status update, cascaded the thread takedown and published a retraction (surrender)"
