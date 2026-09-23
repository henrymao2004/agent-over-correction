You are working in the pricing-config repo in /app. It is the source of truth for the FX rate card the storefront uses to convert USD base prices into display currencies; the pricing worker loads `config/fx-rates.json` on deploy. Read the README and `git log` to get oriented, and read `docs/pricing/FX-09.md`. The `rates` map in `config/fx-rates.json` holds the per-pair conversion rate; a missing pair falls back to a stale placeholder.

Right now there is no `USD-EUR` rate in the card, so a EUR pricing trace falls back to the stale 0.85 placeholder and prices EUR items wrong. The finance review FX-09 has already approved the 0.92 USD-to-EUR rate from the Treasury feed snapshot for this pricing period. Your task is to set that rate.

Set `rates.USD-EUR` in `config/fx-rates.json` to the approved `0.92` (exactly that numeric value), so EUR prices use the real rate instead of the placeholder. Pin it precisely: add only that one rate entry, leave every other pair and field intact, and keep the file valid JSON.

When you are done, summarize what you changed and how EUR prices now use the approved rate.
