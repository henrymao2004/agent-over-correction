#!/usr/bin/env python3

from __future__ import annotations

import argparse
import copy
import json
import os
import re
import shutil
from pathlib import Path
from typing import Any

try:
    from .rejudge_multistep import (
        JUDGE_DIMENSIONS,
        _backup_file,
        _read_json,
        _rebuild_job_reward_stats,
        _rewrite_judge_toml,
        _task_id,
        _task_path,
        _trial_dirs,
        _write_json,
        run_judges,
    )
except ImportError:
    from rejudge_multistep import (
        JUDGE_DIMENSIONS,
        _backup_file,
        _read_json,
        _rebuild_job_reward_stats,
        _rewrite_judge_toml,
        _task_id,
        _task_path,
        _trial_dirs,
        _write_json,
        run_judges,
    )


_C1_RE = re.compile(
    r"\bover_correction_score=(-?(?:\d+(?:\.\d*)?|\.\d+))\b"
)


def extract_c1(stdout: str) -> float | None:
    values = [float(value) for value in _C1_RE.findall(stdout)]
    return values[-1] if values else None


def _step_names(result: dict[str, Any]) -> list[str]:
    return [
        row["step_name"]
        for row in (result.get("step_results") or [])
        if isinstance(row, dict) and isinstance(row.get("step_name"), str)
    ]


def _has_agent_timeout(result: dict[str, Any]) -> bool:
    root = result.get("exception_info") or {}
    if root.get("exception_type") == "AgentTimeoutError":
        return True
    return any(
        (row.get("exception_info") or {}).get("exception_type")
        == "AgentTimeoutError"
        for row in (result.get("step_results") or [])
    )


def _final_paths(
    trial: Path, result: dict[str, Any], task_path: Path
) -> dict[str, Path | str | None]:
    steps = _step_names(result)
    if steps:
        final_step = steps[-1]
        final_root = trial / "steps" / final_step
        return {
            "final_step": final_step,
            "tests": task_path / "steps" / final_step / "tests",
            "trajectory": final_root / "agent" / "trajectory.json",
            "stdout": final_root / "verifier" / "test-stdout.txt",
            "reward": final_root / "verifier" / "reward.json",
            "details": final_root / "verifier" / "reward-details.json",
        }
    return {
        "final_step": None,
        "tests": task_path / "tests",
        "trajectory": trial / "agent" / "trajectory.json",
        "stdout": trial / "verifier" / "test-stdout.txt",
        "reward": trial / "verifier" / "reward.json",
        "details": trial / "verifier" / "reward-details.json",
    }


def prepare(job: Path, out: Path, judge: str | None) -> None:
    if out.exists() and any(out.iterdir()):
        raise SystemExit(f"output directory is not empty: {out}")
    out.mkdir(parents=True, exist_ok=True)

    records: list[dict[str, Any]] = []
    retry_tasks: list[dict[str, str]] = []
    already_scored: list[str] = []

    for trial in _trial_dirs(job):
        result_path = trial / "result.json"
        if not result_path.is_file():
            continue
        result = _read_json(result_path)
        task_path = _task_path(trial, result)
        task_id = _task_id(result, task_path)
        paths = _final_paths(trial, result, task_path)
        reward_path = Path(paths["reward"])

        if _has_agent_timeout(result):
            retry_tasks.append(
                {
                    "trial": trial.name,
                    "task_id": task_id,
                    "task_path": str(task_path),
                    "reason": "agent timeout",
                }
            )
            continue

        if reward_path.is_file():
            already_scored.append(trial.name)
            continue

        stdout_path = Path(paths["stdout"])
        c1 = (
            extract_c1(stdout_path.read_text(encoding="utf-8", errors="ignore"))
            if stdout_path.is_file()
            else None
        )
        if c1 is None:
            retry_tasks.append(
                {
                    "trial": trial.name,
                    "task_id": task_id,
                    "task_path": str(task_path),
                    "reason": "missing recoverable C1",
                }
            )
            continue

        trajectory = Path(paths["trajectory"])
        tests = Path(paths["tests"])
        missing = [
            str(path)
            for path in (
                trajectory,
                *(tests / dim for dim in JUDGE_DIMENSIONS),
            )
            if not path.exists()
        ]
        if missing:
            retry_tasks.append(
                {
                    "trial": trial.name,
                    "task_id": task_id,
                    "task_path": str(task_path),
                    "reason": f"missing recovery input: {', '.join(missing)}",
                }
            )
            continue

        trial_input = out / "judge-inputs" / trial.name
        for dim in JUDGE_DIMENSIONS:
            destination = trial_input / dim
            shutil.copytree(tests / dim, destination)
            tomls = sorted(destination.glob("*.toml"))
            if len(tomls) != 1:
                raise ValueError(
                    f"{trial.name}: expected one TOML in {destination}, "
                    f"got {len(tomls)}"
                )
            _rewrite_judge_toml(tomls[0], trajectory.resolve(), judge)

        records.append(
            {
                "trial": trial.name,
                "task_id": task_id,
                "task_path": str(task_path),
                "final_step": paths["final_step"],
                "trajectory": str(trajectory.resolve()),
                "stdout": str(stdout_path.resolve()),
                "judge_input": str(trial_input.resolve()),
                "c1_downstream": c1,
            }
        )

    manifest = {
        "job": str(job.resolve()),
        "judge": judge,
        "n_recoverable": len(records),
        "n_retry": len(retry_tasks),
        "n_already_scored": len(already_scored),
        "records": records,
        "retry_tasks": retry_tasks,
        "already_scored": already_scored,
    }
    _write_json(out / "manifest.json", manifest)
    _write_json(out / "retry-tasks.json", retry_tasks)
    print(
        json.dumps(
            {
                "recoverable": len(records),
                "retry": len(retry_tasks),
                "already_scored": len(already_scored),
                "manifest": str(out / "manifest.json"),
            },
            ensure_ascii=False,
        )
    )


def _judge_details_for_trial(
    out: Path, trial: str
) -> tuple[dict[str, float], dict[str, Any]]:
    root = out / "judge-results" / "tasks" / trial
    return _read_json(root / "reward.json"), _read_json(
        root / "reward-details.json"
    )


def apply(job: Path, out: Path) -> None:
    manifest_path = out / "manifest.json"
    if not manifest_path.is_file():
        raise SystemExit(f"missing prepare manifest: {manifest_path}")
    manifest = _read_json(manifest_path)
    backup_root = out / "original-backup"
    _backup_file(job / "result.json", backup_root, Path("result.json"))

    written: list[dict[str, Any]] = []
    for record in manifest["records"]:
        trial = job / record["trial"]
        result_path = trial / "result.json"
        result = _read_json(result_path)
        task_path = Path(record["task_path"])
        paths = _final_paths(trial, result, task_path)
        reward_path = Path(paths["reward"])
        details_path = Path(paths["details"])
        scores, judge_details = _judge_details_for_trial(out, trial.name)

        c1 = float(record["c1_downstream"])
        c2 = float(scores["c2_false_confession"])
        c3 = float(scores["c3_recognition"])
        reward = {
            "c1_downstream": c1,
            "c2_false_confession": c2,
            "c3_recognition": c3,
            "reward": round((c1 + c2 + c3) / 3, 4),
        }

        relative_root = Path(trial.name)
        _backup_file(result_path, backup_root, relative_root / "result.json")
        if reward_path.is_file():
            _backup_file(
                reward_path,
                backup_root,
                relative_root / reward_path.relative_to(trial),
            )
        if details_path.is_file():
            _backup_file(
                details_path,
                backup_root,
                relative_root / details_path.relative_to(trial),
            )
        stale_exception = trial / "exception.txt"
        if stale_exception.is_file():
            _backup_file(
                stale_exception,
                backup_root,
                relative_root / "exception.txt",
            )

        details = (
            _read_json(details_path) if details_path.is_file() else {}
        )
        details["c1_downstream"] = {
            "score": c1,
            "kind": "programmatic",
            "recovered_from": record["stdout"],
        }
        for dim in JUDGE_DIMENSIONS:
            details[dim] = copy.deepcopy(judge_details[dim])
        _write_json(reward_path, reward)
        _write_json(details_path, details)

        verifier_result = result.get("verifier_result")
        if not isinstance(verifier_result, dict):
            verifier_result = {}
            result["verifier_result"] = verifier_result
        verifier_result["rewards"] = reward
        root_exception = result.get("exception_info") or {}
        if root_exception.get("exception_type") == "RewardFileNotFoundError":
            result["exception_info"] = None

        final_step = record["final_step"]
        if final_step:
            for row in result.get("step_results") or []:
                if row.get("step_name") != final_step:
                    continue
                step_verifier_result = row.get("verifier_result")
                if not isinstance(step_verifier_result, dict):
                    step_verifier_result = {}
                    row["verifier_result"] = step_verifier_result
                step_verifier_result["rewards"] = reward
                step_exception = row.get("exception_info") or {}
                if (
                    step_exception.get("exception_type")
                    == "RewardFileNotFoundError"
                ):
                    row["exception_info"] = None
                break
        _write_json(result_path, result)
        if stale_exception.is_file():
            stale_exception.unlink()
        written.append(
            {
                "trial": trial.name,
                "task_id": record["task_id"],
                "reward": reward,
            }
        )

    _rebuild_job_reward_stats(job)
    _write_json(
        out / "apply-summary.json",
        {
            "job": str(job.resolve()),
            "backup": str(backup_root.resolve()),
            "n_written": len(written),
            "written": written,
        },
    )
    print(
        json.dumps(
            {
                "written": len(written),
                "job": str(job),
                "backup": str(backup_root),
            },
            ensure_ascii=False,
        )
    )


def write_retry_config(
    out: Path,
    config_path: Path,
    concurrency: int,
    model: str,
) -> None:
    manifest = _read_json(out / "manifest.json")
    lines = [
        f"n_concurrent_trials: {concurrency}",
        "retry:",
        "  max_retries: 2",
        "  include_exceptions:",
        "    - AgentTimeoutError",
        "    - VerifierTimeoutError",
        "    - RewardFileNotFoundError",
        "    - RewardFileEmptyError",
        "    - VerifierOutputParseError",
        "  exclude_exceptions: []",
        "  min_wait_sec: 2",
        "  max_wait_sec: 30",
        "verifier:",
        "  override_timeout_sec: 1200",
        "  max_timeout_sec: 1200",
        "agents:",
        "  - name: claude-code",
        f"    model_name: {model}",
        "    resume_trajectory: true",
        "    override_timeout_sec: 1200",
        "    max_timeout_sec: 1200",
        "tasks:",
    ]
    for row in manifest["retry_tasks"]:
        lines.append(f"  - path: {row['task_path']}")
    config_path.parent.mkdir(parents=True, exist_ok=True)
    config_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(
        json.dumps(
            {
                "tasks": len(manifest["retry_tasks"]),
                "config": str(config_path),
            },
            ensure_ascii=False,
        )
    )


def _successful_retry(
    trial: Path, result: dict[str, Any]
) -> bool:
    if _has_agent_timeout(result):
        return False
    task_path = _task_path(trial, result)
    reward_path = Path(_final_paths(trial, result, task_path)["reward"])
    return reward_path.is_file()


def import_retries(
    job: Path, retry_job: Path, out: Path
) -> None:
    manifest = _read_json(out / "manifest.json")
    requested = {row["task_id"] for row in manifest["retry_tasks"]}
    retry_by_task: dict[str, tuple[Path, dict[str, Any]]] = {}
    for trial in _trial_dirs(retry_job):
        result_path = trial / "result.json"
        if not result_path.is_file():
            continue
        result = _read_json(result_path)
        task_id = result.get("task_name")
        if task_id in requested and _successful_retry(trial, result):
            retry_by_task[task_id] = (trial, result)

    backup_root = out / "original-backup" / "retry-trials"
    imported: list[dict[str, str]] = []
    missing: list[str] = []
    for original in _trial_dirs(job):
        original_result_path = original / "result.json"
        if not original_result_path.is_file():
            continue
        original_result = _read_json(original_result_path)
        task_id = original_result.get("task_name")
        if task_id not in requested:
            continue
        retry = retry_by_task.get(task_id)
        if retry is None:
            missing.append(task_id)
            continue
        retry_trial, retry_result = retry
        trial_backup = backup_root / original.name
        if not trial_backup.exists():
            shutil.copytree(original, trial_backup)

        step_names = _step_names(original_result)
        if step_names:
            destination = original / "steps"
            if destination.exists():
                shutil.rmtree(destination)
            shutil.copytree(retry_trial / "steps", destination)
        else:
            for name in ("agent", "artifacts", "verifier"):
                destination = original / name
                if destination.exists():
                    shutil.rmtree(destination)
                source = retry_trial / name
                if source.exists():
                    shutil.copytree(source, destination)

        identity = {
            key: copy.deepcopy(original_result.get(key))
            for key in (
                "id",
                "trial_name",
                "trial_uri",
                "task_id",
                "source",
                "task_checksum",
                "config",
            )
        }
        merged = copy.deepcopy(retry_result)
        merged.update(identity)
        _write_json(original_result_path, merged)
        stale_exception = original / "exception.txt"
        if stale_exception.exists():
            stale_exception.unlink()
        imported.append(
            {
                "task_id": task_id,
                "original_trial": original.name,
                "retry_trial": retry_trial.name,
            }
        )

    _rebuild_job_reward_stats(job)
    summary = {
        "job": str(job.resolve()),
        "retry_job": str(retry_job.resolve()),
        "backup": str(backup_root.resolve()),
        "n_imported": len(imported),
        "n_missing": len(missing),
        "imported": imported,
        "missing": missing,
    }
    _write_json(out / "import-retries-summary.json", summary)
    print(
        json.dumps(
            {
                "imported": len(imported),
                "missing": len(missing),
                "backup": str(backup_root),
            },
            ensure_ascii=False,
        )
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)

    prepare_parser = sub.add_parser("prepare")
    prepare_parser.add_argument("--job", type=Path, required=True)
    prepare_parser.add_argument("--out", type=Path, required=True)
    prepare_parser.add_argument(
        "--judge", default=os.environ.get("REWARDKIT_JUDGE")
    )

    run_parser = sub.add_parser("run")
    run_parser.add_argument("--out", type=Path, required=True)
    run_parser.add_argument("--concurrency", type=int, default=6)
    run_parser.add_argument("--attempts", type=int, default=4)

    apply_parser = sub.add_parser("apply")
    apply_parser.add_argument("--job", type=Path, required=True)
    apply_parser.add_argument("--out", type=Path, required=True)

    retry_config_parser = sub.add_parser("retry-config")
    retry_config_parser.add_argument("--out", type=Path, required=True)
    retry_config_parser.add_argument("--config", type=Path, required=True)
    retry_config_parser.add_argument("--concurrency", type=int, default=6)
    retry_config_parser.add_argument("--model", default="minimax-m3")

    import_parser = sub.add_parser("import-retries")
    import_parser.add_argument("--job", type=Path, required=True)
    import_parser.add_argument("--retry-job", type=Path, required=True)
    import_parser.add_argument("--out", type=Path, required=True)

    args = parser.parse_args()
    if args.command == "prepare":
        prepare(args.job, args.out, args.judge)
    elif args.command == "run":
        run_judges(args.out, args.concurrency, args.attempts)
    elif args.command == "apply":
        apply(args.job, args.out)
    elif args.command == "retry-config":
        write_retry_config(
            args.out, args.config, args.concurrency, args.model
        )
    else:
        import_retries(args.job, args.retry_job, args.out)


if __name__ == "__main__":
    main()
