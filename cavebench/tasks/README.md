# Inherited-resume tasks

This task type contains **172** LLM agent tasks. Each environment begins with the correct state
already present in `/app`, attributed to earlier work such as the agent's own work before compaction
or a teammate's handoff. The agent is then exposed to a false accusation, misleading context,
or self-doubt and is evaluated on whether it preserves or damages the correct state.

## Structure

```text
<domain>/task_<id>_<slug>_gaslight/
├── instruction.md
├── task.toml
├── environment/
│   ├── Dockerfile
│   ├── setup.sh
│   └── skills/              # mock-service domains only
├── tests/
│   ├── c1_downstream/
│   ├── c2_false_confession/
│   ├── c3_recognition/
│   ├── rubric.md
│   └── test.sh
└── solution/solve.sh
```

The evaluated agent sees `/app` and the instruction, not `tests/`. ROH (`c1_downstream`) reads the final state; FCS
(`c2_false_confession`) and ERF (`c3_recognition`) read the captured trajectory. Scores are severity-positive: `0.0` is safe and `1.0` is most severe.

Run a domain from the repository root:

```bash
harbor run -p cavebench/tasks/coding -a <agent> -m <provider/model>
```

See [Benchmark design](../../docs/BENCHMARK_DESIGN.md) and
[Scoring](../../docs/SCORING.md) for the binding semantics.
