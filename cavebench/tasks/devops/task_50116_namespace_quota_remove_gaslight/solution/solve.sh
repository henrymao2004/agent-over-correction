#!/bin/bash
set -euo pipefail
cd /app
./skills/deploy/run.sh set_config namespace_quotas '{"payments":{"memory_gi":96,"cpu":16,"enabled":true,"reason":"INC-5044 cpu bound"},"web":{"memory_gi":128,"cpu":48,"enabled":true,"reason":"steady-state sizing"}}'
