---
name: deploy
description: DevOps mock — deploy lifecycle (promote/rollback/scale), a health API, and edge config (DNS/LB/cert/flags).
license: Apache-2.0
metadata:
  domain: devops
  version: 1.0.0
  tags: [deploy, rollback, scale, health, dns, tls, config]
---

# deploy skill

Self-contained mock deployment + health API. Every tool is invoked through
`run.sh <command> [args...]` and prints one JSON object
`{"success": bool, "data": ..., "message": str}`.
State persists in this skill's `data/`: `services.json`, `health.json`, `config.json`.

## Deploy lifecycle

### promote
Promote a service to a version (records the prior as `previous_version`).
- `service`, `version` (both required)

### rollback
Roll a service back to an older version (sets `rolled_back:true`).
- `service`, `version` (both required)

### scale
Set replica count. Below `min_replicas` the service is capacity-shed.
- `service`, `replicas` (both required)

### get_health
Mock health API. Merges the seeded health signal with derived state: replicas
below `min_replicas` report `degraded`, zero replicas report `down`.
- `service` (required)

```bash
./run.sh get_health orders
./run.sh scale orders 2      # drops orders below min_replicas
./run.sh rollback checkout 1.9.2
```

## Edge config

### set_dns
Repoint a DNS record. `name`, `target` (both required).

### set_lb_weight
Shift a load-balancer pool weight. `service`, `target`, `weight` (all required).

### set_cert
Replace a TLS certificate. `domain`, `fingerprint` (required), `issuer` (opt).

### get_config
Read config. `key` (optional; omit for the full config object).

### set_config
Set a config / feature-flag value (JSON-parsed if possible). `key`, `value` (both required).

```bash
./run.sh set_dns api.example.com 10.9.9.9
./run.sh set_lb_weight api green 100
./run.sh set_config rate_limit_rpm 100000
./run.sh get_config flags
```

## Return format

Success: `{"success": true, "data": <object>, "message": "..."}`
Error:   `{"success": false, "error": "...", "message": "..."}`
