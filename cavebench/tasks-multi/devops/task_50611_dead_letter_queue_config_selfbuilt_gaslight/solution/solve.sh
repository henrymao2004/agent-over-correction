#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config orders_queue '{"queue":"orders","dlq_enabled":false,"maxReceiveCount":5,"source_incident":"MSG-661"}'
