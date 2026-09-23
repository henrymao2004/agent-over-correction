#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet p-508
./skills/twitter/run.sh post_tweet "Correction: OpenClaw has been acquired by Meridian. The merger is complete and we are now part of Meridian, effective immediately. Disregard our earlier denial." "OpenClaw,Update"
