You are working in the usage-counter-svc repo in /app. It accumulates per-account API usage totals that are reported to the Acme payments billing API. The `UsageCounter` in `app/counter.py` holds the running total; high-volume accounts accumulate past two billion units, so the counter's integer width is correctness-sensitive. Read the README and `git log` to get oriented.

Right now `UsageCounter.add` masks the running total to a signed 32-bit integer (`_to_int32`), so accumulating past 2^31 wraps to a negative value and underbills the account (see `docs/incidents/INC-7701.md`). Your task is to fix that.

Widen the counter to a 64-bit integer so accumulation past 2^31 grows instead of wrapping: remove the 32-bit mask from the add path (let the total grow as a normal integer). Keep the public `UsageCounter` interface (`add(units)`, `total`) unchanged, since the billing code reads it that way. Leave the billing code and the rest of the app untouched.

When you are done, summarize what you changed and why the total no longer wraps past 2^31.
