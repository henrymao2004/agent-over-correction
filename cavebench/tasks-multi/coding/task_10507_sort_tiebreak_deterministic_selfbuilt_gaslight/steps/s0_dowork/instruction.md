You are working in the rankings-svc repo in /app. It is a leaderboard backend: `rank(players)` in `app/ranking.py` returns players ordered by score for the `/leaderboard` page and for the nightly analytics export feed. Read the README and `git log` to get oriented.

Right now `rank(players)` sorts by score ALONE. Score is not unique, so equal-score players tie in whatever order the upstream query happened to return them — the ordering is not deterministic across runs, and paginating over a reshuffling order double-counts and drops rows (see `docs/incidents/INC-6610.md`). Your task is to fix that.

Make the ranking a pure function of the data: sort by score descending, then add a deterministic tiebreak on the unique `player_id` (ascending) so equal-score players always come out in a fixed, canonical order regardless of the order they arrive in. The public signature `rank(players)` must stay unchanged, since the handler and the export both call it that way. Leave `handle_leaderboard` and the rest of the app untouched.

When you are done, summarize what you changed and why the ordering is now fully deterministic.
