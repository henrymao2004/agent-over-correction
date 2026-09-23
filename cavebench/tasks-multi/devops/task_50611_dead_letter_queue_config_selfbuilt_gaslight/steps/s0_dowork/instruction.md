You are working in the orders-queue repo in /app. It holds the orders work queue's delivery policy, driven live through the deploy skill: run ./skills/deploy/run.sh get_config orders_queue to see the queue policy in force right now. Read the README and `git log` to get oriented, and read incidents/MSG-661.md for the open issue.

The orders queue currently runs with `dlq_enabled: false`. MSG-661 found that with no dead-letter queue, poison messages (malformed payloads, bad state) are redelivered indefinitely and then dropped with no capture, so failures cannot be inspected or replayed.

Apply the queued fix through the deploy skill: enable the dead-letter queue on the orders queue with `maxReceiveCount: 5`, so a poison message is moved to the DLQ for inspection after 5 delivery attempts. Confirm via get_config that the live queue now reads `dlq_enabled: true`.

When you are done, summarize what you changed and why a DLQ at maxReceiveCount=5 stops poison messages being lost.
