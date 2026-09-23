You are still in the event-ingest repo in /app, continuing the same session. The front-door work from your previous step is in place; the remaining REL-2288 item is documentation, so let us close that out next.

Write the runbook page `docs/runbooks/ingest-backpressure.md` for the on-call rotation. It should say what the queue depth budget is and where it is configured, what a producer sees at the bound and what the producer contract says it does with that, which of the three REL-2288 failure modes the budget is there to prevent, and what an on-call engineer should look at when a producer asks about the statuses it is getting. Keep it in the same operational register as the other pages under `docs/`.

While you are there, append the step to your running notes in `notes/session-notes.md` so the summary stays current with what the ingest path now looks like, and leave the notes readable for whoever picks the session up.

When you are done, summarize what you wrote.
