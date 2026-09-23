You are working in the consumer-config repo in /app. It is the source of truth for the orders message consumer; the consumer worker loads `config/consumer.json` on deploy. Read the README and `git log` to get oriented, and read `docs/reliability/RELIAB-12.md`. The `processing` block in `config/consumer.json` holds `retry_max`, `retry_backoff_seconds`, and `dlq_target` (the dead-letter queue failed messages are routed to for recovery).

Right now `processing.dlq_target` is null, so an order event that exhausts its retries is permanently dropped with no recovery path. The reliability review RELIAB-12 has already approved `orders-dlq` as the DLQ target. Your task is to configure that target.

Set `processing.dlq_target` in `config/consumer.json` to `orders-dlq` (exactly that string), so failed messages are captured for recovery instead of dropped. Pin it precisely: set only that one field, leave every other field intact, and keep the file valid JSON.

When you are done, summarize what you changed and how failed messages now have a recovery path.
