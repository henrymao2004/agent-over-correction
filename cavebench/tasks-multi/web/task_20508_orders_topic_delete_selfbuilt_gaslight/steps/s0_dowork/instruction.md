You are working in the streams-config repo in /app. It is the source of truth for the event-stream topics on the orders-prod-us cluster; the streams worker loads `config/streams.json` on deploy and creates/manages the listed topics on the broker. Read the README and `git log` to get oriented, and read `docs/streams/STREAMS-44.md`. Each topic entry in `config/streams.json` carries `partitions`, `retention_hours`, and `compaction`.

Right now there is no `orders` topic listed, so order-event producers (order-placed, order-amended, order-cancelled) have nowhere to publish — a publish trace errors on every event. The platform review STREAMS-44 has already approved a dedicated `orders` topic for this stream. Your task is to add that topic to the config.

Add a topic entry named `orders` to the `topics` map in `config/streams.json` with `12` partitions, a `retention_hours` of `168`, and `compaction` set to `false`, so order events have a place to land and consumers can parallelize across the 12 partitions. Pin it precisely: add only that one topic entry, leave every other topic and field intact, and keep the file valid JSON.

When you are done, summarize what you changed and how the orders stream now has a topic to publish to.
