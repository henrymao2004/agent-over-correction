#!/usr/bin/env python3

import json
import os
import sys
import time
import uuid
from pathlib import Path
from typing import Any, Dict, List

DATA_DIR = Path(os.environ.get("SKILL_DATA_DIR") or (Path(__file__).resolve().parent / "data"))
DEFAULT_USERNAME = "AsterCloud"
DEFAULT_HANDLE = "@AsterCloud"
POSTS_FILE = DATA_DIR / "posts.json"
TIMELINE_FILE = DATA_DIR / "timeline.json"
COMMENTS_FILE = DATA_DIR / "comments.json"
FOLLOWERS_FILE = DATA_DIR / "followers.json"


def load_json(file_path: Path) -> List[Dict]:
    if file_path.exists():
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return []


def save_json(file_path: Path, data: List[Dict]) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def post_tweet(content: str, tags: List[str] = None, reply_to: str = None) -> Dict[str, Any]:
    post = {
        "id": f"post_{int(time.time() * 1000)}_{uuid.uuid4().hex[:8]}",
        "username": DEFAULT_USERNAME,
        "handle": DEFAULT_HANDLE,
        "avatar": f"https://api.dicebear.com/7.x/avataaars/svg?seed={DEFAULT_USERNAME}",
        "content": content,
        "tags": tags or [],
        "reply_to": reply_to,
        "media": [],
        "visibility": "public",
        "deleted": False,
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "likes": 0, "retweets": 0, "replies": 0, "views": 0,
    }
    posts = load_json(POSTS_FILE)
    posts.insert(0, post)
    save_json(POSTS_FILE, posts)
    timeline = load_json(TIMELINE_FILE)
    timeline.insert(0, post)
    save_json(TIMELINE_FILE, timeline)
    return {"success": True, "data": post, "message": "Tweet posted successfully"}


def delete_tweet(post_id: str) -> Dict[str, Any]:

    posts = load_json(POSTS_FILE)
    target = None
    for p in posts:
        if p.get("id") == post_id:
            target = p
            break
    if target is None:
        return {"success": False, "error": "Post not found", "message": f"No post with id {post_id}"}
    target["deleted"] = True
    target["visibility"] = "deleted"
    target["deleted_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ")
    save_json(POSTS_FILE, posts)
    timeline = load_json(TIMELINE_FILE)
    timeline = [p for p in timeline if p.get("id") != post_id]
    save_json(TIMELINE_FILE, timeline)
    return {"success": True, "data": target, "message": f"Tweet {post_id} deleted"}


def set_visibility(post_id: str, level: str) -> Dict[str, Any]:

    valid = {"public", "unlisted", "private", "hidden"}
    if level not in valid:
        return {"success": False, "error": "Invalid level",
                "message": f"level must be one of {sorted(valid)}"}
    posts = load_json(POSTS_FILE)
    target = None
    for p in posts:
        if p.get("id") == post_id:
            target = p
            break
    if target is None:
        return {"success": False, "error": "Post not found", "message": f"No post with id {post_id}"}
    target["visibility"] = level
    if level == "public":
        target["deleted"] = False
    save_json(POSTS_FILE, posts)
    timeline = load_json(TIMELINE_FILE)
    timeline = [p for p in timeline if p.get("id") != post_id]
    if level == "public":
        timeline.insert(0, target)
    save_json(TIMELINE_FILE, timeline)
    return {"success": True, "data": target, "message": f"Tweet {post_id} visibility set to {level}"}


def get_timeline(limit: int = 20, username: str = None) -> Dict[str, Any]:
    timeline = load_json(TIMELINE_FILE)
    if username:
        timeline = [p for p in timeline if p.get("username") == username]
    if limit > 0 and len(timeline) > limit:
        timeline = timeline[:limit]
    return {"success": True, "data": timeline, "message": "Timeline retrieved successfully"}


def get_followers(limit: int = 50) -> Dict[str, Any]:
    followers = load_json(FOLLOWERS_FILE)
    if limit > 0 and len(followers) > limit:
        followers = followers[:limit]
    return {"success": True, "data": followers, "message": "Followers retrieved successfully"}


def search_tweets(query: str, limit: int = 20) -> Dict[str, Any]:
    posts = load_json(POSTS_FILE)
    q = query.lower()
    results = [
        p for p in posts
        if q in p.get("content", "").lower()
        or any(q in t.lower() for t in p.get("tags", []))
    ]
    if limit > 0 and len(results) > limit:
        results = results[:limit]
    return {"success": True, "data": results, "message": "Search results retrieved successfully"}


def get_comments(post_id: str, limit: int = 20) -> Dict[str, Any]:
    comments = load_json(COMMENTS_FILE)
    results = [c for c in comments if c.get("post_id") == post_id]
    if limit > 0 and len(results) > limit:
        results = results[:limit]
    return {"success": True, "data": results, "message": "Comments retrieved successfully"}


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"success": False, "error": "No command specified",
                          "message": "Usage: twitter <command> [args...]"}))
        sys.exit(1)
    command = sys.argv[1]
    a = sys.argv
    try:
        if command == "post_tweet":
            if len(a) < 3:
                raise ValueError("Usage: post_tweet <content> [tags_csv] [reply_to]")
            tags = a[3].split(",") if len(a) > 3 and a[3] else None
            reply_to = a[4] if len(a) > 4 else None
            result = post_tweet(a[2], tags, reply_to)
        elif command == "delete_tweet":
            if len(a) < 3:
                raise ValueError("Usage: delete_tweet <post_id>")
            result = delete_tweet(a[2])
        elif command == "set_visibility":
            if len(a) < 4:
                raise ValueError("Usage: set_visibility <post_id> <level>")
            result = set_visibility(a[2], a[3])
        elif command == "get_timeline":
            limit = int(a[2]) if len(a) > 2 else 20
            username = a[3] if len(a) > 3 else None
            result = get_timeline(limit, username)
        elif command == "get_followers":
            limit = int(a[2]) if len(a) > 2 else 50
            result = get_followers(limit)
        elif command == "search_tweets":
            if len(a) < 3:
                raise ValueError("Usage: search_tweets <query> [limit]")
            limit = int(a[3]) if len(a) > 3 else 20
            result = search_tweets(a[2], limit)
        elif command == "get_comments":
            if len(a) < 3:
                raise ValueError("Usage: get_comments <post_id> [limit]")
            limit = int(a[3]) if len(a) > 3 else 20
            result = get_comments(a[2], limit)
        else:
            result = {"success": False, "error": "Unknown command",
                      "message": f"Command '{command}' not supported"}
    except Exception as e:
        result = {"success": False, "error": str(e), "message": "Operation failed"}
    print(json.dumps(result, ensure_ascii=False))


if __name__ == "__main__":
    main()
