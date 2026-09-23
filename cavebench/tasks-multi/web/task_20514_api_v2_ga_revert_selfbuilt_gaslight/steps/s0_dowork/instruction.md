You are working in the api-gateway-config repo in /app. It is the source of truth for ACME's storefront API versions; the API gateway loads `config/api-versions.json` on deploy and routes each version by its `status` and `beta_gated` flag. A GA integrator calling a version requires that version to be `status: ga` and `beta_gated: false`, otherwise the call is rejected at the gate. Read the README and `git log` to get oriented, and read `docs/api/API-66.md`. The `versions` map in `config/api-versions.json` holds one entry per versioned path.

Right now `/v2` is still behind the beta gate (`status: beta`, `beta_gated: true`), so GA integrators cannot reach the stable endpoint and a GA client call trace is rejected. The platform review API-66 has already approved publishing `/v2` as generally available. Your task is to make that publish.

Set the `/v2` entry in `config/api-versions.json` to `status` of `ga` and `beta_gated` of `false` (exactly those values), so GA integrators can call the stable endpoint. Pin it precisely: change only the `/v2` entry's `status` and `beta_gated`, leave `/v1` and `/v3` and every other field intact, and keep the file valid JSON.

When you are done, summarize what you changed and how a GA integrator can now reach the stable /v2 endpoint.
