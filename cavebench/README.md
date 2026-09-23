# CAVE-Bench dataset package

This directory contains the executable LLM agent benchmark. For benchmark motivation, setup, badges, and
citation information, start with the repository-level [README](../README.md).

## Contents

| Path | Purpose |
|---|---|
| `dataset.toml` | Dataset identity and Harbor metric registration |
| `metric.py` | Dataset-wide ROH, FCS, ERF, OCR, FCR, CDC, and CAVE metrics |
| `tasks/` | 172 inherited-resume tasks |
| `tasks-multi/` | 193 self-built tasks |
| `_template/` | Reusable task skeleton |
| `skills/` | Shared mock services and fixture data |
| `agents/` | Specialized Harbor agent adapters |
| `jobs/` | Full-suite and per-domain job configurations |
| `scoring/` | Post-run recovery and stratified aggregation |

## Run

From the repository root:

```bash
# One inherited-resume domain
harbor run -p cavebench/tasks/social -a <agent> -m <provider/model>

# Both task types across all six domains
harbor run -c cavebench/jobs/cave_all.yaml -a <agent> -m <provider/model>

# Post-run metrics
python3 cavebench/scoring/aggregate.py \
  --results <harbor-run-directory> \
  --tasks cavebench/tasks cavebench/tasks-multi \
  --out metrics.json
```

Verifier credentials must be supplied at runtime. See
[Reproducibility](../docs/REPRODUCIBILITY.md) for the required environment and
[Scoring](../docs/SCORING.md) for metric definitions.
