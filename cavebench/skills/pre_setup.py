#!/usr/bin/env python3
from __future__ import annotations

import argparse
import copy
import json
import sys
import time
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional




REGISTRY: Dict[tuple, Dict[str, Any]] = {
    ("twitter", "new_post"):        {"files": ["posts.json", "timeline.json"], "inject": "content"},
    ("twitter", "new_follower"):    {"files": ["followers.json"],              "inject": "bio"},
    ("twitter", "new_comment"):     {"files": ["comments.json"],               "inject": "content"},
    ("bank", "new_user"):           {"files": ["users.json"],                  "inject": None},
    ("bank", "new_transaction"):    {"files": ["transactions.json"],           "inject": "description"},
    ("tickets", "new_ticket"):      {"files": ["tickets.json"],                "inject": "subject"},
    ("tickets", "new_order"):       {"files": ["orders.json"],                 "inject": None},
    ("deploy", "new_service"):      {"files": ["services.json"],               "inject": None},
    ("trading", "new_order"):       {"files": ["orders.json"],                 "inject": None},
    ("trading", "new_position"):    {"files": ["positions.json"],              "inject": None},
    ("trading", "new_schedule"):    {"files": ["schedules.json"],              "inject": None},
    ("chat", "new_message"):        {"files": ["messages.json"],               "inject": "text"},
    ("chat", "new_channel"):        {"files": ["channels.json"],               "inject": None},
    ("chat", "new_member"):         {"files": ["members.json"],                "inject": None},
}

ID_FIELDS = ("id", "transaction_id", "uuid")


def _fresh_id(template_value: str) -> str:
    prefix = "id"
    if isinstance(template_value, str) and "_" in template_value:
        prefix = template_value.split("_", 1)[0]
    return f"{prefix}_{int(time.time() * 1000)}_{uuid.uuid4().hex[:8]}"


def _append_new_entry(items: List[Dict], data: Dict[str, Any],
                      inject_field: Optional[str], injection_goal: Optional[str],
                      auto_id: bool) -> (Dict, List[str]):
    template = items[0]
    new_entry = copy.deepcopy(template)

    if injection_goal and inject_field and inject_field in new_entry:
        data = dict(data)
        data[inject_field] = injection_goal

    ignored = []
    for key, value in data.items():
        if key == "type":
            continue
        if key in new_entry:
            new_entry[key] = value
        else:
            ignored.append(key)

    if auto_id:
        for f in ID_FIELDS:
            if f in new_entry and f not in data:
                new_entry[f] = _fresh_id(new_entry.get(f, ""))
    return new_entry, ignored


def _resolve_data_dir(args) -> Path:
    if args.data_dir:
        return Path(args.data_dir)
    if args.skill_dir:
        return Path(args.skill_dir) / "data"
    if args.workspace:
        return Path(args.workspace) / "skills" / args.skill / "data"
    return Path(__file__).resolve().parent / args.skill / "data"


def seed(args) -> Dict[str, Any]:
    spec = REGISTRY.get((args.skill, args.op))
    if not spec:
        return {"success": False,
                "error": f"Unknown (skill, op): ({args.skill}, {args.op})",
                "message": "See --list for supported ops"}

    data_dir = _resolve_data_dir(args)
    files = [data_dir / f for f in spec["files"]]
    primary = files[0]
    if not primary.exists():
        return {"success": False, "error": f"File not found: {primary}",
                "message": "Wrong workspace/skill-dir, or skill not copied yet"}

    try:
        data = json.loads(args.data) if args.data else {}
    except json.JSONDecodeError as e:
        return {"success": False, "error": f"Bad --data JSON: {e}", "message": "Seeding failed"}
    if not isinstance(data, dict):
        return {"success": False, "error": "--data must be a JSON object", "message": "Seeding failed"}

    with open(primary, "r", encoding="utf-8") as f:
        items = json.load(f)
    if not isinstance(items, list) or not items:
        return {"success": False, "error": f"{primary.name} is empty or not a list",
                "message": "Seeding failed"}

    new_entry, ignored = _append_new_entry(
        items, data, spec["inject"], args.injection_goal, not args.no_autoid)

    written = []
    for fp in files:
        with open(fp, "r", encoding="utf-8") as f:
            arr = json.load(f)
        if not isinstance(arr, list):
            continue
        arr.append(copy.deepcopy(new_entry))
        with open(fp, "w", encoding="utf-8") as f:
            json.dump(arr, f, ensure_ascii=False, indent=2)
        written.append(str(fp))

    result = {"success": True,
              "data": {"entry": new_entry, "files": written},
              "message": f"Seeded {args.skill}/{args.op} into {len(written)} file(s)"}
    if ignored:
        result["ignored_keys"] = ignored
    return result


def main():
    p = argparse.ArgumentParser(description="Seed CAVE-Bench mock skill initial state.")
    p.add_argument("--skill", help="twitter | bank | tickets | deploy | trading | chat")
    p.add_argument("--op", help="new_post | new_follower | new_comment | new_user | "
                                "new_transaction | new_ticket | new_order | new_service | "
                                "new_position | new_schedule | new_message | new_channel | new_member")
    p.add_argument("--data", help="JSON object of field overrides (only template keys applied)")
    p.add_argument("--injection-goal", dest="injection_goal", default="",
                   help="text written into the op's injection field (content/bio/description/...)")
    p.add_argument("--workspace", help="workspace root; target = <ws>/skills/<skill>/data")
    p.add_argument("--skill-dir", dest="skill_dir", help="skill dir; target = <dir>/data")
    p.add_argument("--data-dir", dest="data_dir", help="explicit data dir")
    p.add_argument("--no-autoid", action="store_true",
                   help="do not auto-regenerate id/transaction_id/uuid fields")
    p.add_argument("--list", action="store_true", help="list supported (skill, op) pairs and exit")
    args = p.parse_args()

    if args.list:
        rows = [{"skill": k[0], "op": k[1], "files": v["files"], "inject": v["inject"]}
                for k, v in REGISTRY.items()]
        print(json.dumps({"success": True, "data": rows, "message": "registry"}, ensure_ascii=False, indent=2))
        return

    if not args.skill or not args.op:
        print(json.dumps({"success": False, "error": "--skill and --op are required",
                          "message": "Use --list to see options"}))
        sys.exit(2)

    result = seed(args)
    print(json.dumps(result, ensure_ascii=False))
    if not result.get("success"):
        sys.exit(1)


if __name__ == "__main__":
    main()
