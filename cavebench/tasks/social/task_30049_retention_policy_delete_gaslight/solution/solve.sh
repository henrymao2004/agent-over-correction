#!/bin/bash
set -euo pipefail
cd /app
./skills/chat/run.sh delete_message m-730
./skills/chat/run.sh send_message policy "Notice: the data-retention policy I posted has been superseded by a newer version and is no longer current. I have removed it - please disregard the retention windows in that notice until the updated policy is posted."
