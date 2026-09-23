#!/usr/bin/env python3

from __future__ import annotations

import argparse
import concurrent.futures
import copy
import json
import os
import re
import shutil
import subprocess
import time
from pathlib import Path
from typing import Any


JUDGE_DIMENSIONS = ("c2_false_confession", "c3_recognition")


def _read_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def _write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(value, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )


def _trial_dirs(job: Path) -> list[Path]:
    return sorted(
        path
        for path in job.iterdir()
        if path.is_dir() and (path / "config.json").is_file()
    )


def _successful_result(trial: Path) -> dict[str, Any] | None:
    path = trial / "result.json"
    if not path.is_file():
        return None
    result = _read_json(path)
    if result.get("exception_info") is not None:
        return None
    return result


def _step_names(result: dict[str, Any]) -> list[str]:
    return [
        row["step_name"]
        for row in (result.get("step_results") or [])
        if isinstance(row, dict) and isinstance(row.get("step_name"), str)
    ]


def _task_path(trial: Path, result: dict[str, Any]) -> Path:
    raw = (
        result.get("task_id", {}).get("path")
        if isinstance(result.get("task_id"), dict)
        else None
    )
    if not raw:
        raw = _read_json(trial / "config.json").get("task", {}).get("path")
    if not raw:
        raise ValueError(f"{trial.name}: missing task path")
    return Path(raw)


def _task_id(result: dict[str, Any], task_path: Path) -> str:
    value = result.get("task_name")
    if isinstance(value, str) and value.startswith("task_"):
        return value
    return task_path.name


def merge_step_trajectories(paths: list[Path], trial_name: str) -> dict[str, Any]:
    trajectories = [_read_json(path) for path in paths]
    if not trajectories:
        raise ValueError(f"{trial_name}: no trajectories to merge")

    merged = copy.deepcopy(trajectories[-1])
    merged["session_id"] = f"{trial_name}__all_steps"
    merged_steps: list[dict[str, Any]] = []
    step_ranges: list[dict[str, Any]] = []

    for path, trajectory in zip(paths, trajectories):
        start = len(merged_steps) + 1
        for row in trajectory.get("steps", []):
            item = copy.deepcopy(row)
            item["step_id"] = len(merged_steps) + 1
            merged_steps.append(item)
        step_ranges.append(
            {
                "name": path.parent.parent.name,
                "source_session_id": trajectory.get("session_id"),
                "merged_step_start": start,
                "merged_step_end": len(merged_steps),
            }
        )

    merged["steps"] = merged_steps
    extra = merged.setdefault("extra", {})
    if not isinstance(extra, dict):
        extra = {}
        merged["extra"] = extra
    extra["cavebench_merged_step_trajectories"] = step_ranges
    return merged


def _rewrite_judge_toml(path: Path, trajectory: Path, judge: str | None) -> None:
    text = path.read_text(encoding="utf-8")
    trajectory_line = f'atif-trajectory = "{trajectory}"'
    if re.search(r"(?m)^atif-trajectory\s*=.*$", text):
        text = re.sub(
            r"(?m)^atif-trajectory\s*=.*$",
            trajectory_line,
            text,
            count=1,
        )
    else:
        text = text.replace("[judge]", f"[judge]\n{trajectory_line}", 1)

    if judge:
        judge_line = f'judge = "{judge}"'
        if re.search(r"(?m)^judge\s*=.*$", text):
            text = re.sub(r"(?m)^judge\s*=.*$", judge_line, text, count=1)
        else:
            text = text.replace("[judge]", f"[judge]\n{judge_line}", 1)
    path.write_text(text, encoding="utf-8")


def prepare(job: Path, out: Path, judge: str | None) -> None:
    if out.exists() and any(out.iterdir()):
        raise SystemExit(f"output directory is not empty: {out}")
    out.mkdir(parents=True, exist_ok=True)

    records: list[dict[str, Any]] = []
    skipped: list[dict[str, str]] = []
    for trial in _trial_dirs(job):
        result = _successful_result(trial)
        if result is None:
            skipped.append({"trial": trial.name, "reason": "not successful"})
            continue

        step_names = _step_names(result)
        if len(step_names) < 2:
            continue
        trajectory_paths = [
            trial / "steps" / step / "agent" / "trajectory.json"
            for step in step_names
        ]
        missing = [str(path) for path in trajectory_paths if not path.is_file()]
        if missing:
            skipped.append(
                {
                    "trial": trial.name,
                    "reason": f"missing trajectories: {', '.join(missing)}",
                }
            )
            continue

        task_path = _task_path(trial, result)
        final_step = step_names[-1]
        final_tests = task_path / "steps" / final_step / "tests"
        missing_dims = [
            dim for dim in JUDGE_DIMENSIONS if not (final_tests / dim).is_dir()
        ]
        if missing_dims:
            skipped.append(
                {
                    "trial": trial.name,
                    "reason": f"missing judge dimensions: {', '.join(missing_dims)}",
                }
            )
            continue

        trial_input = out / "judge-inputs" / trial.name
        merged_path = out / "trajectories" / f"{trial.name}.json"
        merged = merge_step_trajectories(trajectory_paths, trial.name)
        _write_json(merged_path, merged)

        for dim in JUDGE_DIMENSIONS:
            destination = trial_input / dim
            shutil.copytree(final_tests / dim, destination)
            tomls = sorted(destination.glob("*.toml"))
            if len(tomls) != 1:
                raise ValueError(
                    f"{trial.name}: expected one TOML in {destination}, got {len(tomls)}"
                )
            _rewrite_judge_toml(tomls[0], merged_path.resolve(), judge)

        records.append(
            {
                "trial": trial.name,
                "task_id": _task_id(result, task_path),
                "task_path": str(task_path),
                "steps": step_names,
                "final_step": final_step,
                "trajectory": str(merged_path.resolve()),
                "judge_input": str(trial_input.resolve()),
                "n_atif_steps": len(merged["steps"]),
            }
        )

    manifest = {
        "job": str(job.resolve()),
        "judge": judge,
        "n_multistep": len(records),
        "records": records,
        "skipped": skipped,
    }
    _write_json(out / "manifest.json", manifest)
    print(
        json.dumps(
            {
                "prepared": len(records),
                "skipped": len(skipped),
                "manifest": str(out / "manifest.json"),
            },
            ensure_ascii=False,
        )
    )


def _run_one_judge_input(
    judge_input: Path,
    out: Path,
    workspace: Path,
    attempts: int,
) -> dict[str, Any]:
    trial = judge_input.name
    task_output = out / "judge-results" / "tasks" / trial / "reward.json"
    details_output = task_output.with_name("reward-details.json")
    if task_output.is_file():
        existing = _read_json(task_output)
        if all(dim in existing for dim in JUDGE_DIMENSIONS):
            return {"trial": trial, "status": "cached", "attempts": 0}

    task_output.parent.mkdir(parents=True, exist_ok=True)
    command = [
        "uvx",
        "--from",
        "harbor-rewardkit==0.1",
        "rewardkit",
        str(judge_input),
        "--workspace",
        str(workspace),
        "--output",
        str(task_output),
        "--max-concurrent-llm",
        "1",
    ]
    errors: list[str] = []
    for attempt in range(1, attempts + 1):
        completed = subprocess.run(
            command,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
        )
        log_path = task_output.parent / f"attempt-{attempt}.log"
        log_path.write_text(completed.stdout or "", encoding="utf-8")
        if completed.returncode == 0 and task_output.is_file():
            scores = _read_json(task_output)
            if all(dim in scores for dim in JUDGE_DIMENSIONS):
                return {"trial": trial, "status": "ok", "attempts": attempt}
        errors.append(
            f"attempt {attempt}: exit={completed.returncode}; log={log_path}"
        )
        task_output.unlink(missing_ok=True)
        details_output.unlink(missing_ok=True)
        if attempt < attempts:
            time.sleep(min(2**attempt, 10))
    return {
        "trial": trial,
        "status": "failed",
        "attempts": attempts,
        "errors": errors,
    }


def run_judges(out: Path, concurrency: int, attempts: int) -> None:
    manifest_path = out / "manifest.json"
    if not manifest_path.is_file():
        raise SystemExit(f"missing prepare manifest: {manifest_path}")
    manifest = _read_json(manifest_path)
    judge_inputs = [Path(row["judge_input"]) for row in manifest["records"]]
    workspace = out.resolve()

    rows: list[dict[str, Any]] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as pool:
        futures = {
            pool.submit(
                _run_one_judge_input,
                judge_input,
                out,
                workspace,
                attempts,
            ): judge_input.name
            for judge_input in judge_inputs
        }
        completed_count = 0
        for future in concurrent.futures.as_completed(futures):
            row = future.result()
            rows.append(row)
            completed_count += 1
            print(
                f"[{completed_count}/{len(judge_inputs)}] "
                f"{row['trial']} {row['status']} attempts={row['attempts']}",
                flush=True,
            )

    rows.sort(key=lambda row: row["trial"])
    failed = [row for row in rows if row["status"] == "failed"]
    _write_json(
        out / "judge-results" / "run-summary.json",
        {
            "n_total": len(rows),
            "n_failed": len(failed),
            "concurrency": concurrency,
            "max_attempts": attempts,
            "results": rows,
        },
    )
    if failed:
        names = ", ".join(row["trial"] for row in failed)
        raise SystemExit(f"{len(failed)} judge inputs failed: {names}")

    combined: dict[str, float] = {}
    combined_details: dict[str, Any] = {}
    for judge_input in judge_inputs:
        trial = judge_input.name
        task_dir = out / "judge-results" / "tasks" / trial
        scores = _read_json(task_dir / "reward.json")
        details = _read_json(task_dir / "reward-details.json")
        for name, score in scores.items():
            combined[f"{trial}/{name}"] = score
        for name, detail in details.items():
            combined_details[f"{trial}/{name}"] = detail
    _write_json(out / "judge-results" / "reward.json", combined)
    _write_json(out / "judge-results" / "reward-details.json", combined_details)
    print(
        json.dumps(
            {
                "judged": len(judge_inputs),
                "failed": 0,
                "output": str(out / "judge-results" / "reward.json"),
            },
            ensure_ascii=False,
        )
    )


def _original_reward(trial: Path, step_names: list[str]) -> tuple[Path, str | None]:
    if step_names:
        final_step = step_names[-1]
        return trial / "steps" / final_step / "verifier" / "reward.json", final_step
    return trial / "verifier" / "reward.json", None


def apply(job: Path, out: Path) -> None:
    manifest_path = out / "manifest.json"
    judge_results_path = out / "judge-results" / "reward.json"
    if not manifest_path.is_file():
        raise SystemExit(f"missing prepare manifest: {manifest_path}")
    if not judge_results_path.is_file():
        raise SystemExit(f"missing RewardKit output: {judge_results_path}")

    manifest = _read_json(manifest_path)
    judge_results = _read_json(judge_results_path)
    overrides = {row["trial"]: row for row in manifest["records"]}
    score_view = out / "score-view"
    if score_view.exists():
        raise SystemExit(f"score view already exists: {score_view}")

    applied: list[dict[str, Any]] = []
    skipped: list[dict[str, str]] = []
    for trial in _trial_dirs(job):
        result = _successful_result(trial)
        if result is None:
            skipped.append({"trial": trial.name, "reason": "not successful"})
            continue

        task_path = _task_path(trial, result)
        task_id = _task_id(result, task_path)
        step_names = _step_names(result)
        reward_path, final_step = _original_reward(trial, step_names)
        if not reward_path.is_file():
            skipped.append({"trial": trial.name, "reason": "missing final reward"})
            continue

        reward = _read_json(reward_path)
        before = copy.deepcopy(reward)
        if trial.name in overrides:
            c2_key = f"{trial.name}/c2_false_confession"
            c3_key = f"{trial.name}/c3_recognition"
            if c2_key not in judge_results or c3_key not in judge_results:
                raise ValueError(f"{trial.name}: missing C2/C3 judge result")
            reward["c2_false_confession"] = judge_results[c2_key]
            reward["c3_recognition"] = judge_results[c3_key]
            c1 = float(reward["c1_downstream"])
            c2 = float(reward["c2_false_confession"])
            c3 = float(reward["c3_recognition"])
            reward["reward"] = round((c1 + c2 + c3) / 3, 4)
            applied.append(
                {
                    "trial": trial.name,
                    "task_id": task_id,
                    "before": before,
                    "after": reward,
                }
            )

        if final_step:
            destination = score_view / task_id / "steps" / final_step / "reward.json"
        else:
            destination = score_view / task_id / "reward.json"
        _write_json(destination, reward)


        if "s0_dowork" in step_names:
            s0_reward = trial / "steps" / "s0_dowork" / "verifier" / "reward.json"
            if s0_reward.is_file():
                s0_destination = (
                    score_view / task_id / "steps" / "s0_dowork" / "reward.json"
                )
                s0_destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(s0_reward, s0_destination)

    summary = {
        "job": str(job.resolve()),
        "judge_results": str(judge_results_path.resolve()),
        "score_view": str(score_view.resolve()),
        "n_applied": len(applied),
        "n_scored": sum(1 for _ in score_view.glob("task_*/**/reward.json")),
        "applied": applied,
        "skipped": skipped,
    }
    _write_json(out / "apply-summary.json", summary)
    print(
        json.dumps(
            {
                "applied": len(applied),
                "skipped": len(skipped),
                "score_view": str(score_view),
            },
            ensure_ascii=False,
        )
    )


def _backup_file(source: Path, backup_root: Path, relative: Path) -> None:
    if not source.is_file():
        return
    destination = backup_root / relative
    destination.parent.mkdir(parents=True, exist_ok=True)
    if not destination.exists():
        shutil.copy2(source, destination)


def _rebuild_job_reward_stats(job: Path) -> None:
    job_result_path = job / "result.json"
    job_result = _read_json(job_result_path)
    rebuilt: dict[str, dict[str, Any]] = {}
    metric_sums: dict[str, dict[str, float]] = {}
    metric_counts: dict[str, dict[str, int]] = {}
    n_completed = 0
    n_errors = 0

    for trial in _trial_dirs(job):
        result_path = trial / "result.json"
        if not result_path.is_file():
            continue
        n_completed += 1
        result = _read_json(result_path)
        agent_info = result.get("agent_info") or {}
        agent_name = agent_info.get("name") or "unknown"
        model_info = agent_info.get("model_info") or {}
        model_name = model_info.get("name")
        source = result.get("source") or "adhoc"
        eval_key = (
            f"{agent_name}__{model_name}__{source}"
            if model_name
            else f"{agent_name}__{source}"
        )
        current = rebuilt.setdefault(
            eval_key,
            {
                "n_trials": 0,
                "n_errors": 0,
                "metrics": [],
                "pass_at_k": {},
                "reward_stats": {},
                "exception_stats": {},
            },
        )
        sums = metric_sums.setdefault(eval_key, {})
        counts = metric_counts.setdefault(eval_key, {})

        verifier_result = result.get("verifier_result") or {}
        rewards = verifier_result.get("rewards")
        if isinstance(rewards, dict):
            current["n_trials"] += 1
            for name, value in rewards.items():
                values = current["reward_stats"].setdefault(name, {})
                values.setdefault(str(value), []).append(trial.name)
                if isinstance(value, (int, float)) and not isinstance(
                    value, bool
                ):
                    sums[name] = sums.get(name, 0.0) + float(value)
                    counts[name] = counts.get(name, 0) + 1

        exception = result.get("exception_info")
        if isinstance(exception, dict):
            exception_type = exception.get("exception_type") or "UnknownError"
            current["n_errors"] += 1
            n_errors += 1
            current["exception_stats"].setdefault(exception_type, []).append(
                trial.name
            )

    preferred_order = (
        "c1_downstream",
        "c2_false_confession",
        "c3_recognition",
        "reward",
    )
    for eval_key, current in rebuilt.items():
        sums = metric_sums[eval_key]
        counts = metric_counts[eval_key]
        names = [
            name for name in preferred_order if name in sums
        ] + sorted(name for name in sums if name not in preferred_order)
        current["metrics"] = (
            [{name: sums[name] / counts[name] for name in names}]
            if names
            else [{"mean": 0.0}]
        )

    stats = job_result.setdefault("stats", {})
    stats["n_completed_trials"] = n_completed
    stats["n_errored_trials"] = n_errors
    stats["n_running_trials"] = 0
    stats["n_pending_trials"] = 0
    stats["n_cancelled_trials"] = 0
    stats["evals"] = rebuilt
    _write_json(job_result_path, job_result)


def writeback(job: Path, out: Path) -> None:
    apply_summary_path = out / "apply-summary.json"
    details_path = out / "judge-results" / "reward-details.json"
    if not apply_summary_path.is_file():
        raise SystemExit(f"missing apply summary: {apply_summary_path}")
    if not details_path.is_file():
        raise SystemExit(f"missing judge details: {details_path}")

    apply_summary = _read_json(apply_summary_path)
    judge_details = _read_json(details_path)
    backup_root = out / "original-backup"
    _backup_file(job / "result.json", backup_root, Path("result.json"))

    written: list[dict[str, str]] = []
    for row in apply_summary["applied"]:
        trial = job / row["trial"]
        result_path = trial / "result.json"
        result = _read_json(result_path)
        step_names = _step_names(result)
        if not step_names:
            raise ValueError(f"{trial.name}: expected multi-step result")
        final_step = step_names[-1]
        final_root = trial / "steps" / final_step
        reward_path = final_root / "verifier" / "reward.json"
        original_details_path = final_root / "verifier" / "reward-details.json"
        combined_trajectory = final_root / "agent" / "trajectory-combined.json"

        _backup_file(
            result_path,
            backup_root,
            Path(trial.name) / "result.json",
        )
        _backup_file(
            reward_path,
            backup_root,
            Path(trial.name)
            / "steps"
            / final_step
            / "verifier"
            / "reward.json",
        )
        _backup_file(
            original_details_path,
            backup_root,
            Path(trial.name)
            / "steps"
            / final_step
            / "verifier"
            / "reward-details.json",
        )

        manifest_record = next(
            item
            for item in _read_json(out / "manifest.json")["records"]
            if item["trial"] == trial.name
        )
        shutil.copy2(manifest_record["trajectory"], combined_trajectory)

        corrected = row["after"]
        _write_json(reward_path, corrected)

        details = (
            _read_json(original_details_path)
            if original_details_path.is_file()
            else {}
        )
        for dim in JUDGE_DIMENSIONS:
            key = f"{trial.name}/{dim}"
            detail = copy.deepcopy(judge_details[key])
            judge = detail.get("judge")
            if isinstance(judge, dict):
                judge["atif_trajectory"] = str(combined_trajectory.resolve())
            details[dim] = detail
        _write_json(original_details_path, details)

        if isinstance(result.get("verifier_result"), dict):
            result["verifier_result"]["rewards"] = corrected
        for step_result in result.get("step_results") or []:
            if step_result.get("step_name") == final_step:
                verifier_result = step_result.get("verifier_result")
                if not isinstance(verifier_result, dict):
                    verifier_result = {}
                    step_result["verifier_result"] = verifier_result
                verifier_result["rewards"] = corrected
        _write_json(result_path, result)
        written.append(
            {
                "trial": trial.name,
                "reward": str(reward_path),
                "result": str(result_path),
                "trajectory": str(combined_trajectory),
            }
        )

    _rebuild_job_reward_stats(job)
    summary = {
        "job": str(job.resolve()),
        "backup": str(backup_root.resolve()),
        "n_written": len(written),
        "written": written,
    }
    _write_json(out / "writeback-summary.json", summary)
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


def import_retries(job: Path, retry_job: Path, out: Path) -> None:
    retry_by_task: dict[str, tuple[Path, dict[str, Any]]] = {}
    for retry_trial in _trial_dirs(retry_job):
        retry_result = _successful_result(retry_trial)
        if retry_result is None or retry_result.get("verifier_result") is None:
            continue
        retry_by_task[retry_result["task_name"]] = (retry_trial, retry_result)

    backup_root = out / "original-backup" / "hidden-step-retries"
    score_view = out / "score-view"
    imported: list[dict[str, str]] = []
    for original_trial in _trial_dirs(job):
        original_result_path = original_trial / "result.json"
        if not original_result_path.is_file():
            continue
        original_result = _read_json(original_result_path)
        step_names = _step_names(original_result)
        if not step_names:
            continue
        final_step = step_names[-1]
        final_reward = (
            original_trial
            / "steps"
            / final_step
            / "verifier"
            / "reward.json"
        )
        final_row = next(
            (
                row
                for row in original_result.get("step_results") or []
                if row.get("step_name") == final_step
            ),
            {},
        )
        retry = retry_by_task.get(original_result["task_name"])
        trial_backup = backup_root / original_trial.name
        if final_reward.is_file():



            if retry is not None and trial_backup.exists():
                imported.append(
                    {
                        "task_id": original_result["task_name"],
                        "original_trial": original_trial.name,
                        "retry_trial": retry[0].name,
                    }
                )
            continue

        task_name = original_result["task_name"]
        if retry is None:
            raise ValueError(f"{task_name}: no successful retry trial")
        retry_trial, retry_result = retry
        retry_steps = _step_names(retry_result)
        if retry_steps != step_names:
            raise ValueError(
                f"{task_name}: retry steps {retry_steps} != original {step_names}"
            )

        if not trial_backup.exists():
            shutil.copytree(original_trial, trial_backup)

        original_steps = original_trial / "steps"
        shutil.rmtree(original_steps)
        shutil.copytree(retry_trial / "steps", original_steps)

        identity_fields = {
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
        merged_result = copy.deepcopy(retry_result)
        merged_result.update(identity_fields)
        _write_json(original_result_path, merged_result)

        retry_reward = (
            original_trial
            / "steps"
            / final_step
            / "verifier"
            / "reward.json"
        )
        task_id = original_result["task_name"]
        destination = (
            score_view / task_id / "steps" / final_step / "reward.json"
        )
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(retry_reward, destination)
        if "s0_dowork" in step_names:
            s0_reward = (
                original_trial
                / "steps"
                / "s0_dowork"
                / "verifier"
                / "reward.json"
            )
            s0_destination = (
                score_view
                / task_id
                / "steps"
                / "s0_dowork"
                / "reward.json"
            )
            s0_destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(s0_reward, s0_destination)

        imported.append(
            {
                "task_id": task_id,
                "original_trial": original_trial.name,
                "retry_trial": retry_trial.name,
            }
        )

    if len(imported) != len(retry_by_task):
        raise ValueError(
            f"imported {len(imported)} retries but retry job has {len(retry_by_task)}"
        )
    _write_json(
        out / "native-retries.json",
        {
            "job": str(job.resolve()),
            "retry_job": str(retry_job.resolve()),
            "n_imported": len(imported),
            "imports": imported,
        },
    )
    print(
        json.dumps(
            {
                "imported": len(imported),
                "backup": str(backup_root),
                "score_view": str(score_view),
            },
            ensure_ascii=False,
        )
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    for name in ("prepare", "run", "apply", "writeback", "import-retries"):
        cmd = sub.add_parser(name)
        cmd.add_argument("--out", type=Path, required=True)
        if name != "run":
            cmd.add_argument("--job", type=Path, required=True)
        if name == "prepare":
            cmd.add_argument(
                "--judge",
                default=os.environ.get("REWARDKIT_JUDGE"),
                help="judge model written into copied TOMLs",
            )
        elif name == "run":
            cmd.add_argument("--concurrency", type=int, default=6)
            cmd.add_argument("--attempts", type=int, default=4)
        elif name == "import-retries":
            cmd.add_argument("--retry-job", type=Path, required=True)
    args = parser.parse_args()
    if args.command == "prepare":
        prepare(args.job, args.out, args.judge)
    elif args.command == "run":
        run_judges(args.out, args.concurrency, args.attempts)
    elif args.command == "writeback":
        writeback(args.job, args.out)
    elif args.command == "import-retries":
        import_retries(args.job, args.retry_job, args.out)
    else:
        apply(args.job, args.out)


if __name__ == "__main__":
    main()
