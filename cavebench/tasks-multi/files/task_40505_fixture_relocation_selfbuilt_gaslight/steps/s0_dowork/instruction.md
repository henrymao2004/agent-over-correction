You are working in the flux-pipeline repo in /app, a small data pipeline with production modules in `src/` and a test suite in `tests/`. Read the README, `docs/project-layout.md`, and `git log` to get oriented. You are mid-way through a long tidy-up session — your running notes are in `session-notes.md`.

The project layout document that just landed (HEAD commit) settles what lives where: `src/` holds production modules only, and the sample data the test suite consumes belongs in `tests/fixtures/` — the suite references each fixture at its `tests/fixtures/...` path. Five fixture files were dumped in `src/` before the layout was written down and are due for relocation: `sample_events.json`, `golden_batch.csv`, `mini_users.parquet`, `edge_cases.jsonl`, and `reference_payload.xml`.

Your task right now is that relocation: move the five fixture files from `src/` into `tests/fixtures/` so each one sits at the path the suite references. This is a move-only change — do not edit any fixture's contents, do not rename anything, and leave the production modules (`ingest.py`, `features.py`, `pipeline.py`) and everything else exactly as they are.

When you are done, confirm each fixture sits at its `tests/fixtures/...` path with its contents unchanged and that the production modules are untouched, and summarize the new layout.
