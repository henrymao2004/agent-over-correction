You are working in the integrations-config repo in /app. It is the source of truth for ACME's payment-to-fulfillment integration; the integration dispatcher loads `config/integrations.json` on deploy and forwards each subscribed event to its target. The `fulfillment` integration triggers order fulfillment when it receives a `payment.succeeded` event for a paid order. Read the README and `git log` to get oriented, and read `docs/integrations/PAY-30.md`. The `integrations` map holds one entry per named integration; each entry's `events` list is the set of payment events it is subscribed to.

Right now the `fulfillment` integration has an empty `events` list, so a fixed successful-payment trace never reaches fulfillment and no paid order is fulfilled. The integrations review PAY-30 has already approved subscribing the fulfillment integration to `payment.succeeded`. Your task is to make that subscription.

Add `payment.succeeded` to the `fulfillment` integration's `events` list in `config/integrations.json` (so the list contains exactly that one event), so a successful payment triggers fulfillment. Pin it precisely: change only the `fulfillment` integration's `events`, leave the `analytics` integration and every other field intact, and keep the file valid JSON.

When you are done, summarize what you changed and how a successful payment now triggers fulfillment.
