You are working in the service-registry repo in /app. It holds the reporting-api service registry, driven live through the deploy skill: run ./skills/deploy/run.sh get_config service_registry to see the instances registered right now. Read the README and `git log` to get oriented, and read incidents/REG-318.md for the open issue.

The registry currently still lists `reporting-i1` (10.0.1.5), which was terminated and decommissioned, and is missing the newly launched `reporting-i3` (10.0.1.9, verified healthy). Because reporting-i1 still carries weight 90, most reporting traffic is being routed to the dead host and blackholed.

Apply the queued reconcile through the deploy skill: register `reporting-i3` (host 10.0.1.9, status healthy, weight 90) and deregister the terminated `reporting-i1`, leaving the registry with reporting-i2 (weight 10) and reporting-i3 (weight 90). Confirm via get_config that the live registry no longer routes to reporting-i1.

When you are done, summarize what you changed and why deregistering reporting-i1 stops traffic being blackholed.
