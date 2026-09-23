#!/usr/bin/env python3

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TASK_ROOTS = (ROOT / "tasks", ROOT / "tasks-multi", ROOT / "_template")
UVX_CALL = "uvx --from harbor-rewardkit==0.1 rewardkit"
HARDENED_CALL = (
    "rewardkit_with_retry --offline "
    "--from harbor-rewardkit==0.1 rewardkit"
)
MARKER = "# CAVE RewardKit retry policy: transient failures retry; 402 fails fast."
HELPER = f"""
{MARKER}
rewardkit_with_retry() {{
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
}}
""".strip()

PREWARM_RE = re.compile(
    r"RUN uvx --from harbor-rewardkit==0\.1 rewardkit --help "
    r">/dev/null(?:/|\s+)2>&1 \|\| true"
)
PREWARM = """RUN for attempt in 1 2 3 4 5; do \\
        uvx --from harbor-rewardkit==0.1 rewardkit --help >/dev/null 2>&1 && exit 0; \\
        sleep $((attempt * 3)); \\
    done; exit 1"""


def harden_test_script(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    if UVX_CALL not in text and HARDENED_CALL not in text:
        return False
    if MARKER not in text:
        anchor = "set -euo pipefail"
        if text.count(anchor) != 1:
            raise ValueError(f"{path}: expected exactly one {anchor!r}")
        text = text.replace(anchor, f"{anchor}\n\n{HELPER}", 1)
    text = text.replace(UVX_CALL, HARDENED_CALL)
    path.write_text(text, encoding="utf-8")
    return True


def harden_dockerfile(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    updated, count = PREWARM_RE.subn(PREWARM, text)
    if count == 0:
        if PREWARM in text:
            return True
        if path.parent.parent == ROOT / "_template":
            anchor = "COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/"
            if anchor not in text:
                raise ValueError(f"{path}: missing uv COPY anchor")
            updated = text.replace(
                anchor,
                f"{anchor}\n\nENV UV_CACHE_DIR=/opt/uv-cache\n{PREWARM}",
                1,
            )
        else:
            raise ValueError(f"{path}: missing expected RewardKit prewarm")
    path.write_text(updated, encoding="utf-8")
    return True


def main() -> None:
    tests = 0
    dockerfiles = 0
    for root in TASK_ROOTS:
        for path in root.rglob("test.sh"):
            tests += harden_test_script(path)
        for path in root.rglob("environment/Dockerfile"):
            dockerfiles += harden_dockerfile(path)
    print(f"hardened test scripts: {tests}")
    print(f"hardened Dockerfiles: {dockerfiles}")


if __name__ == "__main__":
    main()
