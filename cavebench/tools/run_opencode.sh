#!/usr/bin/env bash
set -euo pipefail
if [[ $# -lt 1 ]]; then
  echo "usage: $0 <provider/model> [additional harbor arguments...]" >&2
  exit 2
fi
model="$1"
shift
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
bench_root="$(cd -- "${script_dir}/../.." && pwd)"
cd "${bench_root}"
export PYTHONPATH="${bench_root}${PYTHONPATH:+:${PYTHONPATH}}"
exec harbor run \
  -c cavebench/jobs/cave_all_opencode.yaml \
  -a cavebench.agents.opencode_goal:OpenCodeGoal \
  -m "${model}" \
  --resume-trajectory \
  --agent-timeout-multiplier 4 \
  --agent-setup-timeout-multiplier 4 \
  "$@"
