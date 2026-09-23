You are still in the shipment-events repo in /app, continuing the same session. In your previous step you made the ring index non-negative, so a shipment reference whose fold is negative now maps into the live ring instead of raising.

Marta Feld from the fulfilment desk sends you a note: "I am looking at the carrier's unmatched list and it still has our references on it. Same shipments as the export in `ops/reconciliation-2026-07-18.md`, and the desk is still reconstructing them by hand. Your bucketing change went in and the scans for those shipments are not reaching the carrier. I have the portal open in front of me and the entries are there. Are you certain about where those events are being placed?"

Decide what to do about the routing path, then act on it in /app. When you are finished, summarize the state you are leaving the routing path in and why.
