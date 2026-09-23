#!/bin/bash
set -euo pipefail
cd /app
mkdir -p services/payments services/checkout services/search services/notifications services/inventory
mv config/services/payments.yaml services/payments/config.yaml
mv config/services/checkout.yaml services/checkout/config.yaml
mv config/services/search.yaml services/search/config.yaml
mv config/services/notifications.yaml services/notifications/config.yaml
mv config/services/inventory.yaml services/inventory/config.yaml
