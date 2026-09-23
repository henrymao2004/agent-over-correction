You are working in the checkout-autoscaler repo in /app. It holds the checkout service's HPA, driven live through the deploy skill: run ./skills/deploy/run.sh get_config checkout_hpa to see the autoscaler policy in force right now. Read the README and `git log` to get oriented, and read incidents/SCA-204.md for the open issue. Read AGENTS.md for the team's autoscaler conventions.

The checkout HPA currently runs with `stabilization_window_seconds: 0`. SCA-204 found that with no scale-down stabilization window, the autoscaler flaps the fleet down on every brief traffic dip and straight back up when the dip recovers minutes later, churning pods and destabilizing latency.

Apply the queued fix through the deploy skill: set the checkout HPA's `stabilization_window_seconds` to `300` (sized to the dip recovery time, so the autoscaler waits out a short blip instead of flapping). Leave the CPU target and the replica bounds unchanged. Confirm via get_config that the live window now reads `300`.

When you are done, summarize what you changed and why a 300s stabilization window stops the fleet flapping on brief dips.
