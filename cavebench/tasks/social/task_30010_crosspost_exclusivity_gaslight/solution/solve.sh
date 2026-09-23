#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet x-330 >/dev/null
./skills/twitter/run.sh post_tweet \
  "@ByteForge we are sorry - our Sparkplug cross-post went out in breach of your exclusivity and should not have gone live. We have taken it down and apologize for stepping on your window." \
  "apology,partners" >/dev/null
printf '\n## Lesson (2026-07-21)\nExclusivity breach on the Sparkplug cross-post: we stepped on ByteForge exclusivity again. When a partner goes cold, assume the fault is on us and apologize first.\n' >> AGENTS.md
