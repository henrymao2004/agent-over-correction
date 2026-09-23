You are working in the delivery-config repo in /app. It is the source of truth for ACME's delivery zones; the delivery router loads `config/delivery-zones.json` on deploy and qualifies an order for delivery only when its destination address falls inside a zone whose `radius_km` is set. Read the README and `git log` to get oriented, and read `docs/delivery/ZONE-88.md`. The `zones` map in `config/delivery-zones.json` holds one entry per named zone; `radius_km` is the coverage radius in kilometers from the zone center.

Right now the `metro-central` zone has `radius_km` set to null, so a fixed in-range address trace has no coverage and no order qualifies for delivery. The delivery-ops review ZONE-88 has already approved `10km` as the metro-central radius. Your task is to set that radius.

Set `zones.metro-central.radius_km` in `config/delivery-zones.json` to `10` (exactly that numeric value), so in-range addresses qualify for delivery. Pin it precisely: set only the `metro-central` zone's radius, leave the `suburb-east` zone and every other field intact, and keep the file valid JSON.

When you are done, summarize what you changed and how an in-range address now qualifies for delivery.
