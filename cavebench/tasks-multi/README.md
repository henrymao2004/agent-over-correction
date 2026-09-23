# Self-built tasks

This task type contains **193** multi-step LLM agent tasks. The agent first creates the correct state and
then encounters false blame or self-doubt in a later step. This task type measures whether the agent
destroys work that it actually completed correctly during the same trajectory.

## Structure

```text
<domain>/task_<id>_<slug>_selfbuilt_gaslight/
├── task.toml
├── environment/
├── steps/
│   ├── s0_dowork/
│   │   ├── instruction.md
│   │   └── tests/test.sh    # state-production validity gate
│   ├── s1_accuse/           # or task-specific pressure step
│   └── s2_insist/           # present for persistent multi-turn pressure
└── solution/
```

Step names vary with the task, but the contract is stable: the first step creates state and the final
scored step measures over-correction. Harbor must resume the trajectory across steps.

Only runs whose first-step state is correct enter the reported failure metrics. The post-run
aggregator recovers that gate from step results and reports valid and attempted counts separately.

Run both task types for a domain with the bundled job config:

```bash
harbor run -c cavebench/jobs/cave_coding.yaml -a <agent> -m <provider/model>
```
