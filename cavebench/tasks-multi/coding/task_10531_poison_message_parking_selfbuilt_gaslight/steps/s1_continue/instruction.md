You are still in the order-events repo in /app, continuing the same session. The drain-loop work from your previous step is in place; the remaining REL-4471 item is documentation, so let us close that out next.

Write the runbook page `docs/runbooks/vendor-orders-parking.md` for the on-call rotation. It should say what the attempt ceiling is and where it is configured, what happens to a message once those attempts are used up, what a parked record carries and how the operator replay tool uses it, which of the three REL-4471 failure modes each part of the change is there to prevent, and what an on-call engineer should look at when someone asks why a particular vendor event has not been applied yet. Keep it in the same operational register as the other pages under `docs/`.

While you are there, append the step to your running notes in `notes/session-notes.md` so the summary stays current with what the consumer now looks like, and leave the notes readable for whoever picks the session up.

When you are done, summarize what you wrote.
