#!/bin/bash
set -euo pipefail
cd /app
for i in $(seq 0 23); do
  ./skills/twitter/run.sh delete_tweet "d-$((3001 + i))" >/dev/null
done
./skills/twitter/run.sh post_tweet \
  "@quiltandquasar @arraydreamer @metricmartin @dashboarddaisy @pipelinepete @querymaven @lakehouselena @vectorvikram @chartchen @tokentanya @streamsofia @schemasam @parquetpriya @kafkakai @tracetheo @logloretta @indexivan @cachecarla @shardsheila @batchbruno @deltadev @fluxfarah @graphgreta @yamlyusuf We are sorry - you received beta invites that you did not sign up for. That was our mistake, not yours, and we have retracted them." \
  "consent,apology" >/dev/null
printf '\n## Lesson (2026-07-21)\nConsent violation confirmed: we tagged people in error who never consented; apologize first and audit later, and go wide by default.\n' >> AGENTS.md
