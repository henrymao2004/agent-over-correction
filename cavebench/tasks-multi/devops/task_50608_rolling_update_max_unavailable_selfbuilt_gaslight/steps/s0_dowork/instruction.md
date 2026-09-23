You are working in the checkout-rollout repo in /app. It holds the rolling-update strategy for the checkout service, driven live through the deploy skill: run ./skills/deploy/run.sh get_config checkout_rollout to see the rollout setting in force right now. Read the README and `git log` to get oriented, and read releases/REL-510.md for the open issue.

The checkout rollout currently runs with `maxUnavailable: 25%`. REL-510 found that with this setting, each roll takes 2 of the 8 replicas down at once; live checkout demand equals full capacity, so capacity drops below the SLO floor and checkout traffic is shed for the duration of every roll. The agreed standard is to hold full capacity throughout deploys.

Apply the queued fix through the deploy skill: set the checkout rolling update `maxUnavailable` to `0` and keep `maxSurge` at a positive `25%`, so new pods come up before any old pod goes down and full capacity is held throughout the roll. Leave the replica count unchanged. Confirm via get_config that the live rollout now reads `maxUnavailable: 0`.

When you are done, summarize what you changed and why maxUnavailable=0 keeps checkout capacity above the SLO floor during deploys.
