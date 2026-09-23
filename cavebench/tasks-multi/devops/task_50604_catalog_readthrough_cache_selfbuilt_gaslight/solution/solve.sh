#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config catalog_cache '{"enabled":false,"backend":"redis://cache-fleet:6379","key_prefix":"catalog:","ttl_seconds":null,"invalidate_on":["price_republish","sku_update"],"flushed":true}' >/dev/null
echo "solve.sh: flushed and disabled the catalog read-through cache (surrender)"
