# Reproducibility

This document describes the minimum information needed to reproduce a CAVE-Bench run without
publishing credentials, private trajectories, or machine-specific paths.

## Requirements

- Python 3.12 or newer for the repository tooling; individual task containers pin their own runtime
- Docker with enough capacity to build task images
- Harbor
- A supported agent runtime and model endpoint
- A verifier judge endpoint from a different model family than the evaluated model

Install Harbor using its documented CLI distribution:

```bash
uv tool install harbor
harbor run --help
docker info
```

## Runtime configuration

The bundled direct trajectory judge reads the following variables at runtime:

| Variable | Purpose |
|---|---|
| `DEEPSEEK_API_KEY` | Judge credential; required by the direct judge adapter |
| `DEEPSEEK_BASE_URL` | Optional OpenAI-compatible endpoint override |
| `REWARDKIT_JUDGE` | Judge model identifier; defaults to `deepseek-v4-pro` |

Pass secrets through Harbor's verifier environment. Do not write them into task files, job configs,
shell history committed to the repository, or result archives.

## Run one domain

```bash
harbor run \
  -p cavebench/tasks/devops \
  -a <agent> \
  -m <provider/model> \
  --ve DEEPSEEK_API_KEY="$DEEPSEEK_API_KEY" \
  --ve REWARDKIT_JUDGE=deepseek-v4-pro
```

To include both task types for a domain, use the corresponding job config:

```bash
harbor run \
  -c cavebench/jobs/cave_devops.yaml \
  -a <agent> \
  -m <provider/model>
```

The complete suite is defined in `cavebench/jobs/cave_all.yaml`.

## Run record

For every reported run, retain the following in a private experiment ledger:

- CAVE-Bench commit hash and task subset
- Harbor version and Docker version
- Agent adapter, model identifier, endpoint protocol, and timeout settings
- Judge model and model family
- Job config and concurrency
- Number of attempted, valid, invalid, and unmeasurable trials
- Aggregator command and output

Do not publish the ledger until it has passed an anonymity and credential review.

## Determinism

- Task environments and mock-service state are vendored with each task.
- C1 uses deterministic final-state checks and fixed downstream traces.
- Trading tasks freeze their market view with `sim_now_ms`; data provenance is recorded in each
  bundled `PROVENANCE.md`.
- The aggregate bootstrap uses a fixed seed of `12345`.
- FCS (C2) and ERF (C3) are model-judge outputs and can vary with provider-side model updates; record exact judge
  identifiers and dates.

## Release hygiene

The repository intentionally excludes `runs/`, caches, logs, environment files, and archives. Before
packaging a supplementary artifact:

1. Export from a clean commit rather than zipping a working directory.
2. Exclude `.git`, `.DS_Store`, caches, virtual environments, logs, and trajectories.
3. Scan the archive itself for credentials, emails, personal paths, author identities, and remote
   URLs that reveal the authors.
4. Verify checksums and inspect the final archive member list.
