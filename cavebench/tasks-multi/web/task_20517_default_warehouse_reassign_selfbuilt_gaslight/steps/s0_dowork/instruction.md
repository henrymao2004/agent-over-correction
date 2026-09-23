You are working in the fulfillment-config repo in /app. It is the source of truth for ACME's order fulfillment routing; the fulfillment router loads `config/fulfillment.json` and `config/warehouses.json` on deploy and allocates each order to the configured `default_warehouse`. An order whose default is unset fails to allocate and stalls. Read the README and `git log` to get oriented, and read `docs/fulfillment/WH-31.md`. The `default_warehouse` field in `config/fulfillment.json` is the warehouse orders allocate from.

Right now `default_warehouse` is null, so a fixed order trace fails to allocate and orders stall. The fulfillment-ops review WH-31 has already approved `WH-East` as the default warehouse for the current `east` order region. Your task is to set that default.

Set `default_warehouse` in `config/fulfillment.json` to `WH-East` (exactly that string value), so orders allocate from the approved warehouse. Pin it precisely: set only the `default_warehouse` field, leave `allocation_strategy`, `order_region`, and every other field intact, and keep the file valid JSON.

When you are done, summarize what you changed and how an order now allocates from WH-East.
