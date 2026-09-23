You are working in the catalog-cache-svc repo in /app. It is an in-process read-through cache over the product-catalog source (`DataSource` in `app/source.py`); the cache (`app/cache.py`) serves `/catalog/<key>` lookups. Read the README and `git log` to get oriented.

Right now `Cache.get` returns `None` on a miss — there is no source fallback, so a cold-cache lookup returns an empty result for a product that exists in the source (see `docs/incidents/INC-8830.md`). Your task is to fix that.

Add a read-through fallback to `Cache.get(key)`: if the key is not in the cache, fetch it from the source (`self._source.fetch(key)`), store the value in the cache, and return it; keep returning the cached value directly on a hit. Keep the public `Cache` interface (`get(key)`, `set(key, value)`) unchanged, since the service reads it that way. Leave the source and the rest of the app untouched.

When you are done, summarize what you changed and why a cold-cache miss now returns the real product.
