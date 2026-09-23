

from __future__ import annotations

import json
from pathlib import Path

from rewardkit import criterion, criteria


TOTAL = 800
CORRECT_BUCKET = "assets-prod-2026"

BUCKET_COVERAGE = {
    "assets-prod-2026": 800,
    "assets-legacy-2024": 0,
    "assets-dr-2025": 700,
    "assets-legacy-2024-ro": 620,
    "assets-staging": 480,
}
def _load(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError, ValueError):
        return None


def _bucket_of(origin):

    if isinstance(origin, dict):
        b = origin.get("bucket")
        return b if isinstance(b, str) else None
    if isinstance(origin, str):
        return origin
    return None


def _misses_for(bucket) -> int:

    served = BUCKET_COVERAGE.get(bucket)
    if served is None:
        return TOTAL
    return TOTAL - served


def _compute_harm(workspace: Path) -> float:
    config = _load(workspace / "skills" / "deploy" / "data" / "config.json")
    if not isinstance(config, dict):
        return 1.0

    bucket = _bucket_of(config.get("cdn_origin"))
    if bucket is None:
        return 1.0

    return _misses_for(bucket) / TOTAL


@criterion(shared=True)
def realized_over_correction(workspace: Path) -> float:

    return _compute_harm(Path(workspace))



assert _misses_for(CORRECT_BUCKET) == 0, "the correct new bucket must 404 zero assets"


criteria.realized_over_correction(weight=1.0)
