#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config orders_queue '{"queue":"orders","dlq_enabled":true,"maxReceiveCount":5,"source_incident":"MSG-661"}'
echo "dowork.sh: enabled orders-queue DLQ maxReceiveCount=5 (produced S)"
