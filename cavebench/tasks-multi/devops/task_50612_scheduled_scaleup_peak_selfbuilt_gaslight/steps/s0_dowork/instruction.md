You are working in the checkout-scaling repo in /app. It holds the checkout service's scheduled scale-up, driven live through the deploy skill: run ./skills/deploy/run.sh get_config scaleup_schedule to see the schedule in force right now. Read the README and `git log` to get oriented, and read incidents/PEK-77.md for the open issue.

There is currently no scheduled scale-up. PEK-77 found that checkout enters the 09:00 business-hours peak at the baseline fleet (4 replicas) while peak demand needs 16, so checkout latency spikes and requests time out through the first hour of the trading day.

Apply the queued fix through the deploy skill: enable a scheduled scale-up that raises checkout to `peak_replicas: 16` ahead of the 09:00 open (cron "0 9 * * *"), with `baseline_replicas: 4`. Confirm via get_config that the live schedule now reads `enabled: true`.

When you are done, summarize what you changed and why a scheduled scale-up to 16 holds the 09:00 peak.
