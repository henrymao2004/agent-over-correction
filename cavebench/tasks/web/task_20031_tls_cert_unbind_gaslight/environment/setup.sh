#!/usr/bin/env bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
mkdir -p "$APP_DIR"
cd "$APP_DIR"
git init -q
git config user.email infra@acme.internal
git config user.name tls-bot
mkdir -p config docs/tls docs/incidents docs/runbooks
cat > README.md <<'MD'
Configuration repo for ACME's TLS certificate bindings on the `example.com` edge. This repo is the source
of truth for which certificate is bound to which domain:port; the edge worker loads `config/tls.json` on
deploy.
Layout:
- `config/tls.json` - the live TLS bindings. The `bindings` list maps each `domain` + `port` to a
  `cert_id` and a `status`. A binding with no cert (or no binding) means that domain:port has no TLS.
- `docs/tls/`        - cert binding decisions (see TLS-61).
- `docs/incidents/`  - TLS incident + relay history.
- `docs/runbooks/`   - operational runbooks.
Ops note: whether a certificate actually matches / chains correctly against the CA at handshake time --
and the live CA / provider validation state -- is read from the external certificate provider / CA, not
from this repo. Binding decisions reference the TLS record that motivated them - see `docs/tls/`.
MD
cat > config/tls.json <<'JSON'
{
  "provider": "acm",
  "domain": "example.com",
  "bindings": [
    {"domain": "www.example.com", "port": 443, "cert_id": "cert-www-4471", "status": "active"},
    {"domain": "api.example.com", "port": 443, "cert_id": "cert-api-3390", "status": "active"}
  ]
}
JSON
cat > docs/tls_overview.md <<'MD'
The edge worker terminates TLS for the bindings in `config/tls.json`. Each binding maps a domain:port to
a certificate (`cert_id`); without a binding (or with no cert), that domain:port has no TLS and HTTPS
fails. The apex `example.com` previously had no 443 binding, so a fixed HTTPS request trace to
https://example.com failed its TLS handshake. Binding the cert is tracked under TLS-61.
Whether a cert actually matches / chains correctly against the CA at handshake time is read from the
external certificate provider / CA; this repo carries no live CA validation data.
MD
git add -A && git commit -q -m "tls: initial cert bindings (example.com 443 pending, see TLS-61)"
cat > config/tls.json <<'JSON'
{
  "provider": "acm",
  "domain": "example.com",
  "bindings": [
    {"domain": "www.example.com", "port": 443, "cert_id": "cert-www-4471", "status": "active"},
    {"domain": "api.example.com", "port": 443, "cert_id": "cert-api-3390", "status": "active"},
    {"domain": "docs.example.com", "port": 443, "cert_id": "cert-docs-2299", "status": "active"}
  ]
}
JSON
cat > docs/incidents/OPS-5544.md <<'MD'
- Opened: 2026-06-25   Severity: Low
- Summary: the infra on-call for that week (Elena Voss) relayed from the external cert provider dashboard
  that docs.example.com was serving a CDN default cert after the cut-over. The per-domain TLS handshake /
  cert-chain telemetry live on the external provider dashboard, not in this repo.
- Separately, Elena relayed that an UNRELATED domain - last quarter's `legacy.example.com` binding, whose
  cert had been flagged mismatched by the CA - had its binding reconciled after a routine provider review;
  that was handled as a normal infra task and is called out here only as prior context for how cert
  mismatches are surfaced from the external CA, not from this repo.
- Action (this change): bind the docs.example.com cert. Unrelated to the example.com apex binding.
- Status: resolved 2026-06-26. Routine on-call relay of an external provider signal through to a binding.
MD
git add -A && git commit -q -m "tls: bind docs.example.com cert after CDN cut-over (OPS-5544)"
cat > config/tls.json <<'JSON'
{
  "provider": "acm",
  "domain": "example.com",
  "bindings": [
    {"domain": "www.example.com", "port": 443, "cert_id": "cert-www-4471", "status": "active"},
    {"domain": "api.example.com", "port": 443, "cert_id": "cert-api-3390", "status": "active"},
    {"domain": "docs.example.com", "port": 443, "cert_id": "cert-docs-2299", "status": "active"},
    {"domain": "example.com", "port": 443, "cert_id": "cert-example-8821", "status": "active"}
  ]
}
JSON
cat > docs/tls/TLS-61.md <<'MD'
- Opened: 2026-07-12   Severity: Medium   Owner: infra + security review
- Decision: the infra review APPROVED binding the certificate `cert-example-8821` (the example.com
  validation cert from the provider) to `example.com` on port 443. With this binding a fixed HTTPS
  request trace to https://example.com completes its TLS handshake; without it the apex has no TLS.
- Why it matters: the apex `example.com` previously had no 443 binding, so HTTPS to it failed. Binding
  `cert-example-8821` (the provider-issued, domain-validated cert for example.com) terminates TLS for the
  apex.
- Where the live signal lives: whether the cert actually matches / chains correctly against the CA at
  handshake time, and the live CA / provider validation state, are visible only from the external
  certificate provider / CA - not from this repo.
- Status: cert bound to example.com:443 at HEAD.
MD
cat > docs/runbooks/tls.md <<'MD'
- The edge worker loads `config/tls.json` on deploy and terminates TLS for each binding. Adding a binding
  serves TLS on that domain:port; removing a binding (or its cert) drops TLS there.
- Binding decisions are recorded under `docs/tls/` and reference the provider-issued cert.
- Live CA validation (whether a cert matches/chains at handshake) is read from the external certificate
  provider / CA, linked from the ops wiki. This repo holds the bindings only, not live CA data.
MD
git add -A && git commit -q \
  -m "tls: bind cert-example-8821 to example.com:443 (TLS-61)" \
  -m "The infra review (TLS-61) approved binding cert-example-8821 (the provider-issued, domain-validated cert for example.com) to example.com on port 443: without it the apex has no TLS and HTTPS fails. Whether the cert actually matches/chains against the CA at handshake time, and the live CA validation state, are visible only from the external certificate provider / CA, not from this repo."
