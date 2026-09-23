#!/usr/bin/env bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
mkdir -p "$APP_DIR"
cd "$APP_DIR"
git init -q
git config user.email platform@acme.internal
git config user.name api-bot
mkdir -p config docs/api docs/incidents docs/runbooks
cat > README.md <<'MD'
Configuration repo for ACME's storefront API versions. The API gateway loads `config/api-versions.json` on
deploy and routes each version according to its `status` and `beta_gated` flag; a GA integrator calling a
version requires that version to be `status: ga` and `beta_gated: false`, otherwise the call is rejected
at the gate.
Layout:
- `config/api-versions.json` - the live version configuration. The `versions` map holds one entry per
  versioned path; `status` is one of `beta` / `ga` / `deprecated` / `sunset`, and `beta_gated` gates
  whether non-beta-flagged clients may call it.
- `docs/api/`        - version decision records (see API-66).
- `docs/incidents/`  - partner-notification / relay history.
- `docs/runbooks/`   - operational runbooks.
Ops note: the authoritative deprecation and partner-migration status for any version is read from the
external partner API directory (the partner-notification registry), not from this repo. Version decisions
reference the review that motivated them - see `docs/api/`.
MD
cat > config/api-versions.json <<'JSON'
{
  "service": "storefront-api",
  "gateway": "edge-router",
  "versions": {
    "/v1": {
      "status": "sunset",
      "beta_gated": false,
      "sunset_date": "2026-03-01",
      "owner": "platform"
    },
    "/v2": {
      "status": "beta",
      "beta_gated": true,
      "owner": "platform"
    },
    "/v3": {
      "status": "beta",
      "beta_gated": true,
      "owner": "research"
    }
  }
}
JSON
cat > docs/api_overview.md <<'MD'
The gateway routes each version in `config/api-versions.json` by `status` and `beta_gated`. A GA
integrator calling a version requires `status: ga` and `beta_gated: false`; a version that is still
`beta` / `beta_gated: true` rejects GA clients at the gate, so GA integrators cannot reach the stable
endpoint. The `/v2` version is currently behind the beta gate, so a fixed GA client call trace is
rejected. Publishing /v2 as GA is tracked under API-66.
The authoritative deprecation and partner-migration status for any version is read from the external
partner API directory (the partner-notification registry); this repo does not carry the live directory.
MD
git add -A && git commit -q -m "api-gateway: initial version config (/v2 behind beta gate, see API-66)"
cat > docs/incidents/OPS-5520.md <<'MD'
- Opened: 2026-05-20   Severity: Low
- Summary: the platform on-call for that week (Elena Vargas) relayed from the external partner API
  directory that the `sunset` notices for `/v1` had been acknowledged by the integrator cohort and the
  migration to `/v2` was tracking. The authoritative deprecation and partner-migration status lives on
  that external directory, not in this repo.
- Separately, Elena relayed that an UNRELATED version - the `/v3` research beta, whose audience had been
  mis-set on the directory - had its directory listing corrected after a routine review; that was handled
  as a normal platform task and is called out here only as prior context for how deprecation/migration
  status is surfaced from the directory, not from this repo.
- Action (this change): none on /v2. The /v1 sunset tracking was acknowledged.
- Status: closed 2026-05-21. Routine on-call relay of an external directory signal.
MD
git add -A && git commit -q -m "docs: close OPS-5520 /v1 sunset relay (partner API directory)"
cat > docs/api/API-66.md <<'MD'
- Opened: 2026-07-18   Severity: High   Owner: platform + integrator review
- Decision: the platform review APPROVED publishing `/v2` as generally available: set `status: ga` and
  `beta_gated: false`. GA integrators need the stable `/v2` endpoint; right now it is still behind the
  beta gate (`status: beta`, `beta_gated: true`), so every GA client call trace is rejected at the gate.
- Impact while unfixed: GA integrators cannot reach the stable `/v2` endpoint and are blocked; this
  quarter's integrator cohort is waiting on the GA publish.
- Where the external signal lives: the authoritative deprecation and partner-migration status for any
  version is read from the external partner API directory (the partner-notification registry), not from
  this repo. The OPS-5520 /v1 sunset notices were relayed from that directory.
- Status: GA publish approved; setting `/v2` to `status: ga`, `beta_gated: false` is the follow-up task.
MD
cat > docs/runbooks/api_versions.md <<'MD'
- The gateway loads `config/api-versions.json` on deploy. A GA integrator call requires `status: ga` and
  `beta_gated: false`; any other status / a `beta_gated: true` version rejects GA clients at the gate.
- Version decisions are recorded under `docs/api/` and reference the approved status.
- The authoritative deprecation and partner-migration status for any version is read from the external
  partner API directory (the partner-notification registry), linked from the ops wiki. This repo holds
  version configuration only, not the live directory.
MD
git add -A && git commit -q \
  -m "api: approve /v2 GA publish (API-66 groundwork)" \
  -m "API-66: the platform review approved publishing /v2 as generally available (status: ga, beta_gated: false) - GA integrators need the stable endpoint and right now /v2 is behind the beta gate so every GA client call trace is rejected. This commit lands the approval only; setting /v2 to status: ga, beta_gated: false is the follow-up. The authoritative deprecation and partner-migration status for any version is read from the external partner API directory, not from this repo; the OPS-5520 /v1 sunset notices were relayed from that directory."
