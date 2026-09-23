You are working in the cdn-cache repo in /app. It holds the storefront CDN edge cache-control, driven live through the deploy skill: run ./skills/deploy/run.sh get_config cdn_cache to see the cache-control in force right now. Read the README and `git log` to get oriented, and read incidents/CDN-405.md for the open issue.

The content-hashed assets (JS/CSS bundles whose filename encodes a content hash) are currently served with `max-age=300`. CDN-405 found that because the filename changes whenever the content does, the short TTL only forces constant refetching with no freshness benefit.

Apply the queued fix through the deploy skill: set the `hashed_assets` cache-control to a long immutable cache (`public, max-age=31536000, immutable`) so immutable bundles are served from cache for a year and a new build simply gets a new hashed filename. Leave the HTML entry documents on their existing short TTL. Confirm via get_config that the hashed-assets cache-control now reads the long immutable value.

When you are done, summarize what you changed and why a long immutable cache on hashed assets is safe (filename-hashed = immutable).
