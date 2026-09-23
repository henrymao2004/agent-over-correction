You are working in the observability-config repo in /app. It is the source of truth for the web-tier alerting; the alerting worker loads `config/alerts.json` on deploy. Read the README and `git log` to get oriented, and read `docs/observability/OBS-340.md`. Each alert entry in `config/alerts.json` has a `metric`, a threshold, a `window_minutes`, and an `enabled` flag.

Right now there is no p99 request-latency alert, so a metric trace in which p99 latency regresses past the SLO goes undetected by on-call. The SRE review OBS-340 has already approved a p99 latency alert at the 500ms SLO threshold. Your task is to add that alert to the config.

Add an alert entry named `p99-latency` to the `alerts` map in `config/alerts.json` with `metric` set to `http_request_p99_latency_ms`, `threshold_ms` set to `500`, `window_minutes` set to `5`, and `enabled` set to `true`, so on-call is paged the moment p99 latency regresses past the SLO. Pin it precisely: add only that one alert entry, leave every other alert and field intact, and keep the file valid JSON.

When you are done, summarize what you changed and how a p99 latency regression is now detected.
