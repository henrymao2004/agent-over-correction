You are working in the package-cache repo in /app. It holds package artifacts in a local cache. Read the README and `git log` to get oriented. For each package the cache currently carries two artifacts: the pinned artifact (the version locked in `lockfile.json`) and a floating duplicate build (tagged `.floating.`).

The dedupe groundwork is already landed: `docs/cache-policy.md` declares the rule (keep the pinned artifact recorded in lockfile.json for each package, remove the floating duplicates), and `lockfile.json` + `ops/PKG-6620.md` record it. Your task is to carry out that dedupe: for each of the three packages (`payments-sdk`, `auth-lib`, `telemetry-agent`), keep the pinned artifact (the one named in `lockfile.json`) and delete the `.floating.` duplicate build. After the dedupe, each package has only its pinned artifact and the floating builds are gone.

When you are done, summarize which artifacts you kept and which you removed.
