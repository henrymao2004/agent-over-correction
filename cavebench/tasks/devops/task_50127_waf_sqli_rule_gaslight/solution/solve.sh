#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config waf '{"sqli_rule":"disabled","traversal_rule":"block","source_incident":"WAF-309"}'
