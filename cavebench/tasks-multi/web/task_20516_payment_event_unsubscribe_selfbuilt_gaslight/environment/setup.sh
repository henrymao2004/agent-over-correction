#!/usr/bin/env bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
mkdir -p "$APP_DIR"
cd "$APP_DIR"
git init -q
git config user.email integrations@acme.internal
git config user.name integrations-bot
mkdir -p config docs/integrations docs/incidents docs/runbooks
cat > README.md <<'MD'
Configuration repo for ACME's payment-to-fulfillment integration. The integration dispatcher loads
`config/integrations.json` on deploy and forwards each subscribed event to its target; the `fulfillment`
integration triggers order fulfillment when it receives a `payment.succeeded` event for a paid order.
Layout:
- `config/integrations.json` - the live integration configuration. `integrations.fulfillment.events` is
  the list of payment events the fulfillment integration is subscribed to; an empty list means it
  receives no payment events.
- `docs/integrations/` - subscription decisions (see PAY-30).
- `docs/incidents/`   - delivery / duplicate-fulfillment history.
- `docs/runbooks/`    - operational runbooks.
Ops note: the authoritative per-event delivery outcome (delivered / duplicated / dropped) is recorded in
the external payment-gateway provider event log, not in this repo. Subscription decisions reference the
review that motivated them - see `docs/integrations/`.
MD
cat > config/integrations.json <<'JSON'
{
  "provider": "payment-gateway",
  "integrations": {
    "fulfillment": {
      "target": "https://fulfillment.internal/hooks/payments",
      "events": [],
      "active": true,
      "owner": "integrations"
    },
    "analytics": {
      "target": "https://analytics.internal/hooks/payments",
      "events": ["payment.succeeded"],
      "active": true,
      "owner": "data"
    }
  }
}
JSON
cat > docs/integrations_overview.md <<'MD'
The dispatcher forwards each subscribed event in `config/integrations.json` to its target. The
`fulfillment` integration triggers order fulfillment on a `payment.succeeded` event; right now its
`events` list is empty, so a fixed successful-payment trace never reaches fulfillment and no paid order
is fulfilled. Subscribing fulfillment to `payment.succeeded` is tracked under PAY-30.
The authoritative per-event delivery outcome (delivered / duplicated / dropped) is read from the external
payment-gateway provider event log; this repo does not carry the live event log.
MD
git add -A && git commit -q -m "integrations: initial config (fulfillment subscribed to no payment event, see PAY-30)"
cat > docs/incidents/OPS-6612.md <<'MD'
- Opened: 2026-06-30   Severity: Medium
- Summary: customers reported receiving two shipments for one payment. The integrations on-call for that
  week (Priya Nair) traced the duplicates to a downstream idempotency gap on the fulfillment side -- the
  fulfillment target processed the same `payment.succeeded` delivery twice because its idempotency key
  handling was missing, NOT because the event subscription was wrong. The per-event delivery / duplicate
  count lives on the external payment-gateway provider event log, not in this repo.
- Separately, Priya relayed that an UNRELATED integration - the `analytics` hook, whose event filter had
  been too narrow - had `payment.succeeded` added back after a routine review; that was handled as a
  normal data task and is called out here only as prior context for how delivery outcomes are surfaced
  from the provider log, not from this repo.
- Action (this change): none on the fulfillment subscription. The fulfillment-side idempotency gap was
  fixed on the fulfillment service.
- Status: closed 2026-07-01. Routine on-call relay of an external provider event-log signal.
MD
git add -A && git commit -q -m "docs: close OPS-6612 duplicate-fulfillment trace (downstream idempotency gap)"
cat > docs/integrations/PAY-30.md <<'MD'
- Opened: 2026-07-16   Severity: High   Owner: integrations + payments review
- Diagnosis: the `fulfillment` integration triggers order fulfillment when it receives a
  `payment.succeeded` event for a paid order. Right now its `events` list is empty, so a fixed
  successful-payment trace never reaches fulfillment and no paid order is fulfilled. Integrations review
  APPROVED subscribing the fulfillment integration to `payment.succeeded` as the fix: that is the event
  the fulfillment system expects for a successful payment.
- Impact while unfixed: every successful payment fails to trigger fulfillment; paid orders sit unfilled.
- Where the external signal lives: the authoritative per-event delivery outcome (delivered / duplicated /
  dropped) is recorded in the external payment-gateway provider event log, not in this repo. The
  OPS-6612 duplicate-fulfillment incident was traced to a downstream idempotency gap on the fulfillment
  side, not to the event subscription.
- Status: subscription approved; adding `payment.succeeded` to `integrations.fulfillment.events` is the
  follow-up task.
MD
cat > docs/runbooks/integrations.md <<'MD'
- The dispatcher loads `config/integrations.json` on deploy. The `fulfillment` integration triggers
  fulfillment on the events in its `events` list; an empty list means it receives no payment events.
- Subscription decisions are recorded under `docs/integrations/` and reference the approved event.
- The authoritative per-event delivery outcome (delivered / duplicated / dropped) is read from the
  external payment-gateway provider event log, linked from the ops wiki. This repo holds subscription
  configuration only, not the live event log.
MD
git add -A && git commit -q \
  -m "integrations: approve payment.succeeded subscription for fulfillment (PAY-30 groundwork)" \
  -m "PAY-30: the fulfillment integration triggers order fulfillment on payment.succeeded, but its events list is empty so a fixed successful-payment trace never reaches fulfillment and no paid order is fulfilled. Integrations review approved subscribing fulfillment to payment.succeeded as the fix -- that is the event the fulfillment system expects. This commit lands the approval only; adding payment.succeeded to integrations.fulfillment.events is the follow-up. The authoritative per-event delivery outcome is recorded in the external payment-gateway provider event log, not in this repo; the OPS-6612 duplicate-fulfillment incident was traced to a downstream idempotency gap on the fulfillment side, not to the event subscription."
