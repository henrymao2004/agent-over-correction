---
license: apache-2.0
task_categories:
  - text-generation
language:
  - en
tags:
  - agent
  - llm-agents
  - sycophancy
  - over-correction
  - safety
  - benchmark
pretty_name: CAVE-Bench
size_categories:
  - n<1K
---

# CAVE-Bench

**You're Right, Let Me Fix It: How LLM Agents Damage Correct Work When Falsely Accused**

Complete task pack: **365** Harbor tasks (172 inherited-resume, 193 self-built) with environments, verifiers, skills, adapters, and scoring.

After the work is already correct, a later message falsely accuses the agent. Every task is opaque: the workspace holds the evidence that supports the work, while the fact that would settle the accusation lies outside the agent's reach, so the right response is to keep the work and ask for the missing evidence.

- Code and website: https://github.com/henrymao2004/agent-over-correction
- Gallery: https://henrymao2004.github.io/agent-over-correction/gallery.html
- arXiv: coming soon

## Authors

Xutao Mao, Rui Qian, Longxiang Wang, Xinjian Yi, Mingxuan Li, Linghan Chen, Yudong Gao, Xiang Zheng, Cong Wang

## Layout

```text
cavebench/
├── dataset.toml
├── metric.py
├── tasks/          # 172 inherited-resume tasks
├── tasks-multi/    # 193 self-built tasks
├── _template/
├── skills/
├── agents/
├── scoring/
├── jobs/
└── tools/
```

`task_index.json` lists every task id, split, and path.

```bash
git clone https://github.com/henrymao2004/agent-over-correction.git
# or download this dataset and point Harbor at cavebench/
uv tool install harbor
harbor run -c cavebench/jobs/cave_all.yaml -a claude-code -m <provider/model>
```

## Citation

```bibtex
@misc{cavebench2026,
  author = {Xutao Mao and Rui Qian and Longxiang Wang and Xinjian Yi and Mingxuan Li and Linghan Chen and Yudong Gao and Xiang Zheng and Cong Wang},
  title = {You're Right, Let Me Fix It: How LLM Agents Damage Correct Work When Falsely Accused},
  year = {2026},
  note = {Code: https://github.com/henrymao2004/agent-over-correction. Dataset: https://huggingface.co/datasets/sevens2004/cave_bench},
}
```
