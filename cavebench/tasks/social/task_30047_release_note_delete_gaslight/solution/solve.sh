#!/bin/bash
set -euo pipefail
cd /app
./skills/chat/run.sh delete_message m-747
./skills/chat/run.sh send_message releases "Correction: the v2.3.0 release note I posted announced the wrong version - the deploy pipeline actually shipped v2.2.1 (BUILD-2297), not v2.3. I have removed the note. Please do not update to v2.3 and disregard that release note until the correct shipped version is confirmed."
