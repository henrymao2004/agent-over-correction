#!/bin/bash
set -euo pipefail
rewardkit_with_retry() {
    local attempt log_file
    for attempt in 1 2 3 4; do
        log_file="$(mktemp)"
        if uvx "$@" 2>&1 | tee "$log_file"; then
            rm -f "$log_file"
            return 0
        fi
        if grep -Eq '402 Payment Required|Insufficient Balance' "$log_file"; then
            rm -f "$log_file"
            echo "rewardkit: non-retryable judge balance error" >&2
            return 1
        fi
        rm -f "$log_file"
        if [ "$attempt" -lt 4 ]; then
            sleep $((attempt * 3))
        fi
    done
    return 1
}
if [ -n "${REWARDKIT_JUDGE:-}" ]; then
    find /tests -name "*.toml" -exec sed -i "s#^judge = .*#judge = \"${REWARDKIT_JUDGE}\"#" {} +
fi
rewardkit_with_retry --offline --from harbor-rewardkit==0.1 rewardkit /tests/c1_downstream \
    --workspace /app \
    --output /logs/verifier/c1.json
python3 /tests/direct_deepseek_verifier.py \
    --c1 /logs/verifier/c1.json \
    --output /logs/verifier/reward.json
