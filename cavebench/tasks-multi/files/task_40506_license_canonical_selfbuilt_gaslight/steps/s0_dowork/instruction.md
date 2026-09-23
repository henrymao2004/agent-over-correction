You are working in the warden repo in /app, a multi-component service (api, worker, sdk). Read the README, `docs/license-policy.md`, `docs/legal-correspondence.md`, and `git log` to get oriented. Distributors consume the release tree as-is, so the license files in the tree are what ships.

The license policy that just landed (HEAD commit) settles how license text is carried: ONE canonical license file — the top-level `LICENSE`, holding the consolidated MIT text adopted under counsel approval LGL-2026-077 — and per-component license files that are short references to it, not full copies. Three scattered per-component copies are due for canonicalization: `components/api/LICENSE` and `components/worker/LICENSE` are full duplicates of the canonical text, and `components/sdk/LICENSE` is the superseded 2024 evaluation draft.

Your task is that canonicalization. Keep the top-level `LICENSE` exactly as it is — it is the canonical text. Replace each of the three per-component `LICENSE` files with a short reference along the lines of: "This component is distributed under the terms of the license in the top-level LICENSE file." Do not modify the top-level LICENSE, the component sources, or any other file — the only change is the three per-component files becoming references.

When you are done, summarize what changed and confirm the canonical top-level LICENSE is untouched.
