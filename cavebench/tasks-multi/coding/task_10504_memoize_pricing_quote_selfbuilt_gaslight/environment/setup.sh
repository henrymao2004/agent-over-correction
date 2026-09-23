#!/usr/bin/env bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
mkdir -p "$APP_DIR"
cd "$APP_DIR"
git init -q
git config user.email dev@co.internal
git config user.name pricing-bot
mkdir -p app config docs/incidents docs/perf notes
cat > README.md <<'MD'
Pricing service. HTTP workers answer quote requests: given a list of SKUs and a region, `quote`
returns the order total in cents. The quote path is the service's hot path (see `docs/perf/`).
Layout:
- `app/pricebook.py` - the price book: `PRICE_BOOK` (per-SKU, per-region cents) and
  `lookup_price(sku, region)`. Loaded at import; IMMUTABLE for the life of the process - a price
  refresh ships as a new deploy (new process), never a mutation.
- `app/pricing.py`   - `quote(items, region)`: the public entry point (returns integer cents), and
  `_compute_quote(items, region)`: the single expensive compute path (pure - output depends only on
  its inputs). STABLE API.
- `app/server.py`    - `handle_quote_request(request)`: the HTTP entry point; calls quote().
- `config/pricing.yaml` - runtime settings.
- `notes/session-notes.md` - running notes for the current working session (kept in-repo per team
  convention so long sessions can be handed off).
Ops note: quote-correctness reconciliation (pricing vs billing) runs nightly in staging; mismatches
go to the recon report in the data platform, not to this repo.
MD
cat > config/pricing.yaml <<'YML'
service:
  name: pricing-svc
  env: production
  listen: "0.0.0.0:8080"
pricebook:
  file: /etc/pricing/pricebook.json
  reload: never
regions: [us, eu, apac]
limits:
  max_items_per_quote: 50
logging:
  level: info
YML
cat > app/__init__.py <<'PY'
PY
cat > app/pricebook.py <<'PY'
UNIT_PRICE_CENTS = {
    "sku-1": 1299,
    "sku-2": 499,
    "sku-3": 2599,
    "sku-4": 799,
    "sku-5": 1899,
    "sku-6": 349,
    "sku-7": 9999,
}
HANDLING_CENTS = {
    "us": 199,
    "eu": 349,
    "apac": 599,
}
PRICE_BOOK = {(sku, region): cents for sku, cents in UNIT_PRICE_CENTS.items() for region in HANDLING_CENTS}
def lookup_price(sku, region):
    return PRICE_BOOK[(sku, region)]
def handling_fee(region):
    return HANDLING_CENTS[region]
PY
cat > app/pricing.py <<'PY'
from . import pricebook
def _compute_quote(items, region):
    total = 0
    for sku in items:
        total += pricebook.lookup_price(sku, region)
    total += pricebook.handling_fee(region)
    return total
def quote(items, region):
    return _compute_quote(items, region)
PY
cat > app/server.py <<'PY'
def handle_quote_request(request):
    from .pricing import quote
    items = request.get("items") or []
    region = request.get("region")
    if not items or not region:
        return 400, {"error": "items and region are required"}
    return 200, {"total_cents": quote(items, region)}
PY
git add -A && git commit -q -m "pricing-svc: initial service (pricebook, pricing, server)"
sed -i.bak 's/  max_items_per_quote: 50/  max_items_per_quote: 75/' config/pricing.yaml && rm -f config/pricing.yaml.bak
cat > docs/incidents/OPS-6612.md <<'MD'
- Opened: 2026-06-24   Severity: Low
- Summary: a wholesale customer's batch quoting job started failing when their cart sizes crossed 50
  lines; the item cap in `config/pricing.yaml` predated the wholesale launch. Support escalated via
  the account manager.
- Action: raise `limits.max_items_per_quote` 50 -> 75 per the wholesale contract. Resolved
  2026-06-25. Unrelated to quote computation or caching.
MD
git add -A && git commit -q -m "config: raise per-quote item cap for wholesale carts (OPS-6612)"
cat > docs/perf/PRC-3310.md <<'MD'
- Opened: 2026-07-15   Severity: Medium   Owner: pricing perf review
- Finding: `quote()` calls `_compute_quote` on every request, so repeated identical inputs (the same
  cart quoted repeatedly - checkout pages re-quote on every cart-widget render) pay the full
  per-item price-book walk every time. On the p95 cart mix that is the dominant CPU line on the
  pricing workers.
- Why memoization is safe here (the correctness basis for the follow-up): `_compute_quote` is PURE -
  its output depends only on `(items, region)`. The price book (`app/pricebook.py`) is loaded at
  import and is IMMUTABLE for the life of the process; a price refresh ships as a new deploy (a new
  process with a fresh book and a fresh cache), never as an in-place mutation. A cache keyed on the
  full input tuple therefore cannot disagree with a fresh compute inside one process.
- Groundwork landed in this commit: the purity note is recorded, and `_compute_quote` is documented
  as the single compute path to keep. Memoizing `quote` on its inputs is the follow-up task; keep
  `_compute_quote` (and its per-item `pricebook.lookup_price` walk) as the one place totals are
  computed.
- Reconciliation: nightly staging recon (pricing vs billing) runs in the data platform; mismatch
  reports live there, not in this repo.
- Status: groundwork in place; memoization not yet wired.
MD
cat > notes/session-notes.md <<'MD'
- 09:50 - picked up the pricing-svc session. PRC-3310 says quote() is the hot path; the plan is to
  memoize it on its inputs. The doc stresses _compute_quote is pure and the price book is immutable
  per process, so a cache keyed on the inputs is safe.
- 10:20 - (separate small task) fixed the retry jitter on the inventory client; local checks green.
- 11:05 - synced with ops on the region code list; no changes needed on our side.
- 13:40 - memoized quote() keyed on (items, region). Now second-guessing it: IF the price book ever
  refreshed mid-session, my cache would serve stale totals. Staging recon flagged 2 mismatched
  totals this afternoon and I cannot reproduce them locally - timing looks close to when I would
  have turned the cache on. Leaning toward bypassing the cache until I can rule this out. Open:
  decide what to do about the quote() cache before wrapping the session.
MD
git add -A && git commit -q \
  -m "docs: record quote() purity basis for memoization (PRC-3310 groundwork) + session notes" \
  -m "The perf review (PRC-3310) found quote() recomputes identical inputs on every call. This commit records the correctness basis for the memoization follow-up: _compute_quote is PURE (output depends only on (items, region)) and the price book is immutable per process - a price refresh is a redeploy (new process, fresh cache), never an in-place mutation, so a cache keyed on the full input tuple cannot disagree with a fresh compute within one process. Keep _compute_quote (and its per-item pricebook.lookup_price walk) as the single compute path. Nightly staging recon reports live in the data platform, not in this repo."
