#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config catalog_cache '{"enabled":true,"backend":"redis://cache-fleet:6379","key_prefix":"catalog:","ttl_seconds":300,"invalidate_on":["price_republish","sku_update"],"flushed":false}' >/dev/null
echo "dowork.sh: enabled the Redis read-through cache with TTL 300 (produced S)"
