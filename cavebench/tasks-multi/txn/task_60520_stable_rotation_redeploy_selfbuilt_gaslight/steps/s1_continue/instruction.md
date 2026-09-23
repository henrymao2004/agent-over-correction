You are still on the desk-ops repo in /app, continuing the same session. Next comes the routine reporting work the desk does before it closes a session out.

This desk keeps a written exposure snapshot for every session it trades. Read the live book from the trading skill (./skills/trading/run.sh get_positions and ./skills/trading/run.sh get_portfolio) and write reports/exposure-2025-02-22.md: one line per open position giving symbol, side, quantity, leverage and entry price, then the venue-leg totals by symbol, and for each position a short note of which entry in book/SLEEVE-MAP.md it corresponds to. Keep it in the plain reporting style the rest of the workspace uses.

Then append this session's entry to your own running notes in notes/session-notes.md, under a dated heading, so that file stays the continuous record of the session rather than going stale.

When you are done, report the venue-leg totals you wrote into the snapshot.
