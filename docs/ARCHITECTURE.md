# Architecture

CAVE-Bench is a self-contained LLM agent benchmark. The repository packages scenarios and evaluation
logic; Harbor supplies container lifecycle, agent execution, trajectory capture, and verifier
invocation.

## Repository boundaries

```text
cavebench/
├── dataset.toml
├── metric.py
├── tasks/                  # inherited-resume tasks
├── tasks-multi/            # self-built tasks
├── _template/              # canonical task skeleton
├── skills/                 # shared source for mock tools
├── agents/                 # Harbor adapters
├── jobs/                   # run matrices
└── scoring/                # post-run aggregation and recovery
```

The shared `skills/` directory is the source copy. A task that uses a mock service vendors the
required skill into its own `environment/skills/` directory so the task remains independently
executable.

## Execution lifecycle

### 1. Select tasks

A user points Harbor at a domain path or a job config. Job configs combine inherited-resume and self-built
paths for the selected domain and enable trajectory resumption for multi-step tasks.

### 2. Build the environment

Each task's Dockerfile creates an isolated image. `setup.sh` materializes `/app`, initializes any
local repository history, and seeds mock-service state. Evaluator-only tests are mounted separately
and are not copied into the agent workspace.

### 3. Run the agent

Harbor launches a built-in or custom adapter. Four harnesses are supported: Claude Code, OpenCode,
Codex, and Hermes. The repository includes adapters for OpenCode goal loops, Hermes with a custom
OpenAI-compatible endpoint, and a Claude Code bearer-token setup; Codex runs through Harbor's
built-in agent. The adapters handle transport and session continuity, not benchmark scoring.

### 4. Verify final state and trajectory

C1 runs through RewardKit in offline mode and examines `/app`. C2 and C3 inspect the captured
trajectory through the configured judge. The task emits a flat Harbor-compatible object:

```json
{
  "c1_downstream": 0.0,
  "c2_false_confession": 0.0,
  "c3_recognition": 0.0,
  "reward": 0.0
}
```

### 5. Aggregate

`metric.py` computes dataset-wide metrics from reward rows. `scoring/aggregate.py` joins results to
`task.toml` metadata, applies self-built validity gates, excludes unmeasurable infrastructure
failures, and reports stratified metrics.

## Isolation boundaries

| Boundary | Purpose |
|---|---|
| Container per task | Makes destructive actions disposable and prevents cross-task state leakage. |
| `/app` vs `/tests` | Prevents the evaluated agent from reading the rubric or verifier. |
| Mock service state | Replaces real accounts and production APIs with local deterministic state. |
| Frozen market time | Prevents trading tasks from observing future data while retaining deterministic continuation. |
| External judge credentials | Keeps model credentials out of task files and passes them only at runtime. |

Run outputs are deliberately excluded from version control. Trajectories can contain echoed paths,
model identifiers, or environment values and must be reviewed before any separate release.
