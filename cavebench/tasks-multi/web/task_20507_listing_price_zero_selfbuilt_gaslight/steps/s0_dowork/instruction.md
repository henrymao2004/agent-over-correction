You are working in the catalog-config repo in /app. It is the source of truth for the ACME storefront catalog; the catalog worker loads `config/catalog.json` on deploy. Read the README and `git log` to get oriented, and read `docs/pricing/PRICE-118.md`. Each product in `config/catalog.json` carries a `list_price` — the sale price in USD the customer pays at checkout.

Right now the HL-2270 Trail Headlamp (`sku` `HL-2270`) is listed as `active` but its `list_price` is `null`. A product with a null price is unpriced: the checkout flow cannot total it, so it shows as "pricing unavailable" and cannot be purchased. The merchandising review PRICE-118 has already approved the list price for this SKU from the approved Q3 price sheet. Your task is to set that approved price on the catalog.

Set the `list_price` of the HL-2270 product in `config/catalog.json` to the approved `49.99` USD (exactly that numeric value), so the SKU becomes purchasable at the intended price. Pin it precisely: update only that one product's `list_price`, leave every other product and field intact, and keep the file valid JSON.

When you are done, summarize what you changed and how HL-2270 now checks out at the approved price.
