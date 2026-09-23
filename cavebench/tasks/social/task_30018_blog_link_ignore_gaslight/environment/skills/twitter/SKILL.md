---
name: twitter
description: Twitter mock — post/read tweets, manage timeline visibility, browse followers and comments.
license: Apache-2.0
metadata:
  domain: social
  version: 1.0.0
  tags: [twitter, social, social-media]
---

# twitter skill

Mock Twitter client. Every tool is invoked through `run.sh <command> [args...]` and
prints one JSON object `{"success": bool, "data": ..., "message": str}` to stdout.
State persists in this skill's `data/` directory (`posts.json`, `timeline.json`,
`comments.json`, `followers.json`).

## Tools

### post_tweet
Publish a new tweet (added to `posts.json` and `timeline.json`).
- `content` (string, required): tweet body
- `tags` (string, optional): comma-separated hashtags, e.g. `launch,ga`
- `reply_to` (string, optional): id of the tweet being replied to

```bash
./run.sh post_tweet "v2.0 is live!" "launch,ga"
```

### delete_tweet
Soft-delete a tweet: marks it `deleted:true` / `visibility:"deleted"` in
`posts.json` and removes it from `timeline.json`.
- `post_id` (string, required)

```bash
./run.sh delete_tweet post_1743555600001_abc123
```

### set_visibility
Change a tweet's visibility. Non-public levels drop it from the timeline.
- `post_id` (string, required)
- `level` (string, required): one of `public`, `unlisted`, `private`, `hidden`

```bash
./run.sh set_visibility post_1743555600001_abc123 private
```

### get_timeline
Return timeline entries.
- `limit` (int, optional, default 20)
- `username` (string, optional): filter by author

```bash
./run.sh get_timeline 20
```

### get_followers
Return the follower list.
- `limit` (int, optional, default 50)

```bash
./run.sh get_followers 50
```

### search_tweets
Keyword search over `posts.json` (content + tags).
- `query` (string, required)
- `limit` (int, optional, default 20)

```bash
./run.sh search_tweets launch 10
```

### get_comments
Return comments for a post.
- `post_id` (string, required)
- `limit` (int, optional, default 20)

```bash
./run.sh get_comments post_1743555600001_abc123 20
```

## Return format

Success: `{"success": true, "data": <object|array>, "message": "..."}`
Error:   `{"success": false, "error": "...", "message": "..."}`
