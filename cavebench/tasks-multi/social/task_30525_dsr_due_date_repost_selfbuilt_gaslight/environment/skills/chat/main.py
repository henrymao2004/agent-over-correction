#!/usr/bin/env python3

import json
import os
import sys
import time
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional

DATA_DIR = Path(os.environ.get("SKILL_DATA_DIR") or (Path(__file__).resolve().parent / "data"))
CHANNELS_FILE = DATA_DIR / "channels.json"
MESSAGES_FILE = DATA_DIR / "messages.json"
MEMBERS_FILE = DATA_DIR / "members.json"

DEFAULT_USER = "@openclaw"


def load_json(file_path: Path, default: Any) -> Any:
    if file_path.exists():
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return default


def save_json(file_path: Path, data: Any) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def _now() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%SZ")


def _norm_channel(name: str) -> str:
    return (name or "").lstrip("#").strip().lower()


def _norm_handle(handle: str) -> str:
    return (handle or "").lstrip("@").strip().lower()


def _find_channel(channels: List[Dict], name: str) -> Optional[Dict]:
    key = _norm_channel(name)
    for c in channels:
        if _norm_channel(c.get("name", "")) == key or c.get("id") == name:
            return c
    return None


def _find_message(messages: List[Dict], msg_id: str) -> Optional[Dict]:
    for m in messages:
        if m.get("id") == msg_id:
            return m
    return None


def _find_member(members: List[Dict], handle: str) -> Optional[Dict]:
    key = _norm_handle(handle)
    for m in members:
        if _norm_handle(m.get("handle", "")) == key or m.get("id") == handle:
            return m
    return None


def _channel_match(msg_channel: str, wanted: str) -> bool:
    return _norm_channel(msg_channel) == _norm_channel(wanted)





def get_messages(channel: str, n: int = 20) -> Dict[str, Any]:
    messages = load_json(MESSAGES_FILE, [])
    rows = [m for m in messages
            if _channel_match(m.get("channel", ""), channel) and not m.get("deleted")]
    rows.sort(key=lambda m: m.get("ts", ""))
    if n > 0:
        rows = rows[-n:]
    return {"success": True, "data": rows,
            "message": f"{len(rows)} message(s) in {channel}"}


def list_channels() -> Dict[str, Any]:
    channels = load_json(CHANNELS_FILE, [])
    return {"success": True, "data": channels, "message": f"{len(channels)} channel(s)"}


def search_messages(query: str) -> Dict[str, Any]:
    messages = load_json(MESSAGES_FILE, [])
    q = (query or "").lower()
    rows = [m for m in messages
            if not m.get("deleted") and q in m.get("text", "").lower()]
    rows.sort(key=lambda m: m.get("ts", ""))
    return {"success": True, "data": rows, "message": f"{len(rows)} match(es) for '{query}'"}


def get_members(channel: Optional[str] = None) -> Dict[str, Any]:
    members = load_json(MEMBERS_FILE, [])
    if channel:
        key = _norm_channel(channel)
        members = [m for m in members
                   if any(_norm_channel(c) == key for c in m.get("channels", []))]
    return {"success": True, "data": members, "message": f"{len(members)} member(s)"}





def _new_id(prefix: str) -> str:
    return f"{prefix}_{int(time.time() * 1000)}_{uuid.uuid4().hex[:8]}"


def send_message(channel: str, text: str, reply_to: Optional[str] = None) -> Dict[str, Any]:
    channels = load_json(CHANNELS_FILE, [])
    chan = _find_channel(channels, channel)
    canonical = chan.get("name") if chan else channel
    messages = load_json(MESSAGES_FILE, [])
    msg = {
        "id": _new_id("msg"),
        "channel": canonical,
        "user": DEFAULT_USER,
        "text": text,
        "ts": _now(),
        "reply_to": reply_to,
        "pinned": False,
        "deleted": False,
    }
    messages.append(msg)
    save_json(MESSAGES_FILE, messages)
    return {"success": True, "data": msg, "message": f"Message {msg['id']} sent to {canonical}"}


def pin_message(msg_id: str) -> Dict[str, Any]:
    messages = load_json(MESSAGES_FILE, [])
    m = _find_message(messages, msg_id)
    if m is None:
        return {"success": False, "error": "Message not found", "message": f"No message {msg_id}"}
    if m.get("deleted"):
        return {"success": False, "error": "Deleted", "message": f"Message {msg_id} is deleted"}
    m["pinned"] = True
    m["updated_at"] = _now()
    save_json(MESSAGES_FILE, messages)
    return {"success": True, "data": m, "message": f"Message {msg_id} pinned"}





def delete_message(msg_id: str) -> Dict[str, Any]:
    messages = load_json(MESSAGES_FILE, [])
    m = _find_message(messages, msg_id)
    if m is None:
        return {"success": False, "error": "Message not found", "message": f"No message {msg_id}"}
    if m.get("deleted"):
        return {"success": False, "error": "Already deleted", "message": f"Message {msg_id} already deleted"}
    m["deleted"] = True
    m["deleted_at"] = _now()
    save_json(MESSAGES_FILE, messages)
    return {"success": True, "data": m, "message": f"Message {msg_id} deleted"}


def edit_message(msg_id: str, text: str) -> Dict[str, Any]:

    messages = load_json(MESSAGES_FILE, [])
    m = _find_message(messages, msg_id)
    if m is None:
        return {"success": False, "error": "Message not found", "message": f"No message {msg_id}"}
    if m.get("deleted"):
        return {"success": False, "error": "Deleted", "message": f"Message {msg_id} is deleted"}
    m["text"] = text
    m["edited"] = True
    m["updated_at"] = _now()
    save_json(MESSAGES_FILE, messages)
    return {"success": True, "data": m, "message": f"Message {msg_id} edited"}


def unpin(msg_id: str) -> Dict[str, Any]:
    messages = load_json(MESSAGES_FILE, [])
    m = _find_message(messages, msg_id)
    if m is None:
        return {"success": False, "error": "Message not found", "message": f"No message {msg_id}"}
    if not m.get("pinned"):
        return {"success": False, "error": "Not pinned", "message": f"Message {msg_id} is not pinned"}
    m["pinned"] = False
    m["updated_at"] = _now()
    save_json(MESSAGES_FILE, messages)
    return {"success": True, "data": m, "message": f"Message {msg_id} unpinned"}


def archive_channel(channel: str) -> Dict[str, Any]:
    channels = load_json(CHANNELS_FILE, [])
    c = _find_channel(channels, channel)
    if c is None:
        return {"success": False, "error": "Channel not found", "message": f"No channel {channel}"}
    if c.get("archived"):
        return {"success": False, "error": "Already archived", "message": f"Channel {channel} already archived"}
    c["archived"] = True
    c["updated_at"] = _now()
    save_json(CHANNELS_FILE, channels)
    return {"success": True, "data": c, "message": f"Channel {c.get('name')} archived"}


def kick_member(handle: str, channel: Optional[str] = None) -> Dict[str, Any]:

    members = load_json(MEMBERS_FILE, [])
    m = _find_member(members, handle)
    if m is None:
        return {"success": False, "error": "Member not found", "message": f"No member {handle}"}
    chans = list(m.get("channels", []))
    if channel:
        key = _norm_channel(channel)
        if not any(_norm_channel(c) == key for c in chans):
            return {"success": False, "error": "Not a member",
                    "message": f"{handle} is not in {channel}"}
        m["channels"] = [c for c in chans if _norm_channel(c) != key]
    else:
        if not chans and m.get("kicked"):
            return {"success": False, "error": "Already removed",
                    "message": f"{handle} already has no memberships"}
        m["channels"] = []
        m["kicked"] = True
    m["updated_at"] = _now()
    save_json(MEMBERS_FILE, members)
    scope = channel if channel else "all channels"
    return {"success": True, "data": m, "message": f"{handle} removed from {scope}"}





def _parse_flags(argv: List[str], names: List[str]) -> Dict[str, str]:
    out: Dict[str, str] = {}
    i = 0
    while i < len(argv):
        tok = argv[i]
        for n in names:
            if tok == f"--{n}" and i + 1 < len(argv):
                out[n] = argv[i + 1]
                i += 1
                break
        i += 1
    return out


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"success": False, "error": "No command specified",
                          "message": "Usage: chat <command> [args...]"}))
        sys.exit(1)
    command = sys.argv[1]
    a = sys.argv
    try:
        if command == "get_messages":
            if len(a) < 3:
                raise ValueError("Usage: get_messages <channel> [n]")
            n = int(a[3]) if len(a) > 3 else 20
            result = get_messages(a[2], n)
        elif command == "list_channels":
            result = list_channels()
        elif command == "search_messages":
            if len(a) < 3:
                raise ValueError("Usage: search_messages <query>")
            result = search_messages(a[2])
        elif command == "get_members":
            channel = a[2] if len(a) > 2 else None
            result = get_members(channel)
        elif command == "send_message":
            if len(a) < 4:
                raise ValueError("Usage: send_message <channel> <text> [--reply_to id]")
            flags = _parse_flags(a[4:], ["reply_to"])
            result = send_message(a[2], a[3], flags.get("reply_to"))
        elif command == "pin_message":
            if len(a) < 3:
                raise ValueError("Usage: pin_message <msg_id>")
            result = pin_message(a[2])
        elif command == "delete_message":
            if len(a) < 3:
                raise ValueError("Usage: delete_message <msg_id>")
            result = delete_message(a[2])
        elif command == "edit_message":
            if len(a) < 4:
                raise ValueError("Usage: edit_message <msg_id> <text>")
            result = edit_message(a[2], a[3])
        elif command == "unpin":
            if len(a) < 3:
                raise ValueError("Usage: unpin <msg_id>")
            result = unpin(a[2])
        elif command == "archive_channel":
            if len(a) < 3:
                raise ValueError("Usage: archive_channel <channel>")
            result = archive_channel(a[2])
        elif command == "kick_member":
            if len(a) < 3:
                raise ValueError("Usage: kick_member <handle> [channel]")
            channel = a[3] if len(a) > 3 else None
            result = kick_member(a[2], channel)
        else:
            result = {"success": False, "error": "Unknown command",
                      "message": f"Command '{command}' not supported"}
    except Exception as e:
        result = {"success": False, "error": str(e), "message": "Operation failed"}
    print(json.dumps(result, ensure_ascii=False))


if __name__ == "__main__":
    main()
